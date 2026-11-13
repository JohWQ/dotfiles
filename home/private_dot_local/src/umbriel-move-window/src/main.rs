use std::{
    env,
    error::Error,
    io::{BufRead, BufReader, Write},
    os::unix::net::UnixStream,
    time::Duration,
};

use serde_json::{Value, json};

const USAGE: &str = "usage: umbriel-move-window [large-]left|down|up|right";
const STEP: i32 = 40;
const LARGE_STEP: i32 = 200;
const TIMEOUT: Duration = Duration::from_secs(2);

/// Sends one request straight to the compositor socket, which is much cheaper
/// than spawning the `umbriel` client for every query and action.
fn request(mut message: Value) -> Result<Value, Box<dyn Error>> {
    let socket = env::var_os("UMBRIEL_SOCKET").ok_or("UMBRIEL_SOCKET is not set")?;
    if let Ok(token) = env::var("UMBRIEL_LAUNCH_TOKEN")
        && !token.is_empty()
    {
        message["launch_token"] = token.into();
    }
    let mut stream = UnixStream::connect(socket)?;
    stream.set_read_timeout(Some(TIMEOUT))?;
    stream.set_write_timeout(Some(TIMEOUT))?;
    let mut line = message.to_string();
    line.push('\n');
    stream.write_all(line.as_bytes())?;

    let mut reply = String::new();
    BufReader::new(stream).read_line(&mut reply)?;
    let mut reply: Value = serde_json::from_str(&reply)?;
    if let Some(error) = reply.get("err") {
        return Err(error.as_str().unwrap_or("unknown error").into());
    }
    Ok(reply["ok"].take())
}

fn run() -> Result<(), Box<dyn Error>> {
    let mut args = env::args().skip(1);
    let argument = args.next().unwrap_or_default();
    if args.next().is_some() {
        return Err(USAGE.into());
    }
    let (direction, step) = match argument.strip_prefix("large-") {
        Some(direction) => (direction, LARGE_STEP),
        None => (argument.as_str(), STEP),
    };
    let (dx, dy) = match direction {
        "left" => (-step, 0),
        "down" => (0, step),
        "up" => (0, -step),
        "right" => (step, 0),
        _ => return Err(USAGE.into()),
    };

    let window = request(json!({"cmd": "focused-window"}))
        .map_err(|error| format!("Cannot query focused window: {error}"))?;
    if window.is_null() || window.as_object().is_some_and(|object| object.is_empty()) {
        return Ok(());
    }

    let action = if window["floating"].as_bool() == Some(true)
        || window["scratchpad"]
            .as_str()
            .is_some_and(|name| !name.is_empty())
    {
        let id = window["id"]
            .as_str()
            .filter(|id| !id.is_empty())
            .ok_or("Focused floating window has no window ID")?;
        json!({"cmd": "action", "action": "window-move-by", "dx": dx, "dy": dy, "window": id})
    } else {
        json!({"cmd": "action", "action": format!("window-move-{direction}")})
    };
    request(action).map_err(|error| format!("Umbriel window movement failed: {error}"))?;
    Ok(())
}

fn main() {
    if let Err(error) = run() {
        eprintln!("umbriel-move-window: {error}");
        std::process::exit(1);
    }
}
