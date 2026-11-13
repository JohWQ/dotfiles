use std::{env, error::Error, fs, io::Write, path::PathBuf, process::Command};
use toml_edit::{DocumentMut, Item, Table, value};

type Result<T> = std::result::Result<T, Box<dyn Error>>;

fn update_settings(original: &str, output: &str, restore: bool) -> Result<Option<String>> {
    let mut document = original.parse::<DocumentMut>()?;
    let keys = [
        ("margin_edge", if restore { 2 } else { 0 }),
        ("margin_ends", if restore { 20 } else { 0 }),
        ("radius", if restore { 20 } else { 0 }),
        ("radius_top_left", if restore { 20 } else { 0 }),
        ("radius_top_right", if restore { 20 } else { 0 }),
        ("radius_bottom_left", if restore { 20 } else { 0 }),
        ("radius_bottom_right", if restore { 20 } else { 0 }),
    ];
    let mut table = document.as_table_mut();
    for key in ["bar", "default", "monitor", output] {
        if !table.contains_key(key) {
            let mut child = Table::new();
            child.set_implicit(true);
            table.insert(key, Item::Table(child));
        }
        table = table
            .get_mut(key)
            .and_then(Item::as_table_mut)
            .ok_or_else(|| format!("Expected a table at {key}"))?;
    }
    if keys
        .iter()
        .all(|(key, expected)| table.get(key).and_then(Item::as_integer) == Some(*expected))
    {
        return Ok(None);
    }
    table.set_implicit(false);
    for (key, number) in keys {
        table.insert(key, value(number));
    }
    Ok(Some(document.to_string()))
}

fn run() -> Result<()> {
    let response = Command::new("umbriel")
        .args(["focused-window", "--json"])
        .output()?;
    if !response.status.success() {
        return Err(format!(
            "Cannot query focused window: {}",
            String::from_utf8_lossy(&response.stderr).trim()
        )
        .into());
    }
    let window: serde_json::Value = serde_json::from_slice(&response.stdout)?;
    let restore = window["maximized_to_edges"]
        .as_bool()
        .ok_or("Missing maximize state")?;
    let output = window["output"]
        .as_str()
        .filter(|name| !name.is_empty())
        .ok_or("Focused window has no output; bar settings unchanged")?;
    let state_home = match env::var_os("XDG_STATE_HOME") {
        Some(path) => PathBuf::from(path),
        None => PathBuf::from(env::var_os("HOME").ok_or("HOME is not set")?).join(".local/state"),
    };
    let settings = state_home.join("noctalia/settings.toml");
    let original = match fs::read_to_string(&settings) {
        Ok(text) => text,
        Err(error) if error.kind() == std::io::ErrorKind::NotFound => String::new(),
        Err(error) => return Err(error.into()),
    };
    let updated = update_settings(&original, output, restore)?;
    if !Command::new("umbriel")
        .args(["msg", "window-toggle-maximize-to-edges"])
        .status()?
        .success()
    {
        return Err("Umbriel maximize action failed; bar settings unchanged".into());
    }
    if let Some(updated) = updated {
        let directory = settings.parent().ok_or("Settings path has no parent")?;
        fs::create_dir_all(directory)?;
        let mut temporary = tempfile::Builder::new()
            .prefix(".bar-style-")
            .suffix(".tmp")
            .tempfile_in(directory)?;
        temporary.write_all(updated.as_bytes())?;
        temporary.persist(&settings)?;
    }
    // Noctalia watches this file. Explicit reloads can cause extra redraws.
    Ok(())
}

fn main() {
    if let Err(error) = run() {
        eprintln!("umbriel-maximize: {error}");
        std::process::exit(1);
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn updates_only_selected_monitor_and_preserves_widgets() {
        let original = "# retained comment\n[bar.default]\nradius = 20\n[bar.default.monitor.DP-3]\nstart = [\"clock\"]\nmargin_edge = 7\n";
        let updated = update_settings(original, "DP-1", false).unwrap().unwrap();
        assert!(updated.contains("# retained comment"));
        let parsed = updated.parse::<DocumentMut>().unwrap();
        assert_eq!(parsed["bar"]["default"]["radius"].as_integer(), Some(20));
        assert_eq!(
            parsed["bar"]["default"]["monitor"]["DP-3"]["margin_edge"].as_integer(),
            Some(7)
        );
        assert_eq!(
            parsed["bar"]["default"]["monitor"]["DP-1"]["radius"].as_integer(),
            Some(0)
        );
        assert!(update_settings(&updated, "DP-1", false).unwrap().is_none());
        let restored = update_settings(&updated, "DP-1", true)
            .unwrap()
            .unwrap()
            .parse::<DocumentMut>()
            .unwrap();
        assert_eq!(
            restored["bar"]["default"]["monitor"]["DP-1"]["margin_ends"].as_integer(),
            Some(20)
        );
        let other = update_settings(&updated, "DP-3", false)
            .unwrap()
            .unwrap()
            .parse::<DocumentMut>()
            .unwrap();
        assert_eq!(
            other["bar"]["default"]["monitor"]["DP-3"]["start"][0].as_str(),
            Some("clock")
        );
    }

    #[test]
    fn handles_missing_settings_and_rejects_invalid_toml() {
        let updated = update_settings("", "DP.1", false).unwrap().unwrap();
        assert!(
            updated.parse::<DocumentMut>().unwrap()["bar"]["default"]["monitor"]
                .get("DP.1")
                .is_some()
        );
        assert!(update_settings("[broken", "DP-1", false).is_err());
    }
}
