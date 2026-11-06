# Dotfiles

Managed with [chezmoi](https://www.chezmoi.io/). The desktop uses Umbriel and
Noctalia. See [AGENTS.md](AGENTS.md) for editing and validation guidelines.

## Restore

On Linux, set the hostname and restore its age key to
`~/.config/chezmoi/age.key` with permissions `600`, then run:

```sh
chezmoi init https://github.com/JohWQ/dotfiles.git
chezmoi diff --exclude=scripts
chezmoi apply
```

Update with `chezmoi update`. Linux apply scripts install packages.

| Host | Configuration |
| --- | --- |
| `cachyos-desktop` | Linux configs, Umbriel, desktop Noctalia settings and encrypted secrets. |
| `cachyos-laptop` | Linux configs, laptop display settings and encrypted Noctalia settings. |
| `windows-desktop` | Separate Neovim, Yazi and PowerShell 7 configs; pinned Yazi plugins. |

### Windows

UniGetUI manages system packages through its GitHub cloud backup:

1. Install UniGetUI:

   ```powershell
   winget install --exact --id Devolutions.UniGetUI --source winget
   ```

2. Sign in and select the `WINDOWS-DESKTOP\<username>` backup. Restore it before
   enabling automatic backups on a fresh installation. Install the selection
   from **Package Bundles**, including chezmoi, Git, PowerShell 7, Neovim, Yazi,
   Starship and zoxide.
3. Open PowerShell 7 and run the restore commands above, then `. $PROFILE`.

Windows configs live under `home/readonly_AppData/` and
`home/readonly_Documents/`. Linux installation scripts are excluded.

## Configuration

`home/` is the chezmoi source root. `root/` contains system configuration
references and is not applied by chezmoi.

### Umbriel

The desktop config is `~/.config/umbriel/config.toml`. Adjust `[[window_rule]]`
entries for window sizes and `[output.*]` for monitors. Validate edits with
`umbriel config validate`.

Shortcuts also use the local `umbriel-move-window` and `umbriel-maximize`
executables, which must be installed separately. OCR requires grim, slurp,
Tesseract (English and Norwegian), and wl-clipboard; drawing requires wayscriber
and its user service.

### Niri

The Niri configs require [`biri-git`](https://github.com/barrulus/biri#fork-features)
for sticky floating windows. Fork-dependent settings and bindings are marked with
`// biri-git (niri fork) feature(s):`; remove or adapt them to use upstream Niri.

Hidden workspaces (used by the scratchpad bindings):
```sh
cargo install --git https://github.com/argosnothing/niri-scratchpad-rs.git --branch=hidden-workspaces
```

### Noctalia

Shared defaults are in `home/dot_config/noctalia/private_config.toml.tmpl`.
Files under `home/.chezmoitemplates/noctalia/hosts/` override them by hostname:

- `<hostname>.toml`: displays, wallpapers, plugins and other host preferences.
- `<hostname>.age`: encrypted location settings and API keys, applied last.

Unknown hosts use shared defaults. Enabled plugins download automatically;
plugin code and runtime state are excluded from Git.

**Back up each host's age key outside this repository.** Desktop and laptop
keys are separate. Edit templates or host overrides; never re-add the generated
Noctalia config, which contains decrypted secrets.

Refresh Noctalia on an initialized machine:

```sh
chezmoi apply ~/.config/noctalia/config.toml ~/restore-noctalia-plugins.sh
```

The restore script clears selected stale runtime overrides and reloads Noctalia.
If a setting still does not apply, compare `~/.config/noctalia/config.toml` with
`~/.local/state/noctalia/settings.toml` and remove the relevant runtime override.
Check plugins with `noctalia msg plugins list`.

### Yazi

`package.toml` pins downloaded plugins and flavors; `ya pkg install` restores
them. Only the custom `confirm-quit.yazi` plugin is stored in Git. After an
intentional `ya pkg upgrade`, capture the new pins with:

```sh
chezmoi re-add ~/.config/yazi/package.toml
```

## Linux tools

For Yazi's file-view integration:

```sh
yay -S xdg-desktop-portal-termfilechooser-hunkyburrito-git

git clone https://github.com/boydaihungst/org.freedesktop.FileManager1.common
cd org.freedesktop.FileManager1.common
meson setup build --reconfigure
sudo ninja -C build install
```

Inspired by [hankertrix/Dotfiles](https://github.com/hankertrix/Dotfiles).
