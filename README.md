# Dotfiles - managed by chezmoi

Work in progress.

Initialize and apply dotfiles on Linux (review the host policy below first):
```sh
chezmoi init --apply https://github.com/JohWQ/dotfiles.git
```

Update dotfiles:
```sh
chezmoi update
```

`chezmoi apply` installs packages defined in `<chezmoi-source-directory>/run_onchange_before_install-...-packages.sh.tmpl`
Other installed binaries are pulled from the files:

The `<chezmoi-source-directory>/root` directory is not tracked by Chezmoi.

### Host and operating-system policy

| System | Restore behavior |
| --- | --- |
| `cachyos-desktop` on Linux | Shared Linux dotfiles plus desktop Noctalia overrides and encrypted secrets. |
| `cachyos-laptop` on Linux | Shared Linux dotfiles plus laptop Noctalia overrides and encrypted location settings. |
| Native Windows host `windows-desktop` | Separate Windows Neovim, Yazi, and PowerShell configs, once captured; Linux dotfiles and installation scripts are excluded. |
| Other native Windows hosts, or WSL named `windows-desktop` | No dotfiles or installation scripts are applied by default. |

Windows uses independent application configs rather than the Linux Neovim and
Yazi files. On native `windows-desktop`, `home/.chezmoiignore` allows only these
future source locations:

| Application | Separate chezmoi source location |
| --- | --- |
| Neovim | `home/AppData/Local/nvim/` |
| Yazi | `home/AppData/Roaming/yazi/config/` |
| PowerShell 7 | `home/Documents/PowerShell/` |
| Windows PowerShell 5.1 | `home/Documents/WindowsPowerShell/` |

These Windows configs have not been captured yet. Add the actual Windows files
on that host with `chezmoi add`, checking Neovim's `:echo stdpath('config')`,
Yazi's `%APPDATA%\yazi\config`, and PowerShell's `$PROFILE` for their real paths.
Redirected AppData or Documents paths (for example, OneDrive Documents) need
matching source paths and ignore exceptions. The default paths are documented by
[Neovim](https://neovim.io/doc/user/starting/),
[Yazi](https://yazi-rs.github.io/docs/configuration/overview/), and
[PowerShell](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_profiles).

Other Windows hosts and WSL named `windows-desktop` remain excluded. Windows
application paths are also excluded on Linux. Chezmoi's initialization config
can still be generated.

Use `~/...` for user-home paths in application configs that support it, including
Noctalia avatar and wallpaper settings. When an application requires an absolute
path, generate it in a `.tmpl` file with `.chezmoi.homeDir` and `joinPath`; avoid
hardcoded `/home/<username>` paths. Desktop launchers use generated absolute paths.

The laptop's Noctalia customizations have been collected. Before applying on
either machine, compare `chezmoi diff --exclude=scripts` with the local files.
Hostname selection applies to Noctalia and the captured Niri input, shortcut,
window-size, and output settings. Other Linux dotfiles remain shared. Add hostname/OS conditions to those templates as
actual differences are collected. Do not copy desktop monitor layouts or
secrets into the laptop override file.

### Optional dependencies:
```sh
# aur packages:
yay -S xdg-desktop-portal-termfilechooser-hunkyburrito-git biri-git
# or use shelly:
# shelly xdg-desktop-portal-termfilechooser-hunkyburrito-git wayscriber-bin
# shelly biri-git
# shelly wayscriber-bin

# org.freedesktop.FileManager1.common (yazi file view):
git clone https://github.com/boydaihungst/org.freedesktop.FileManager1.common
cd org.freedesktop.FileManager1.common
meson setup build --reconfigure
sudo ninja -C build install
```

### Noctalia: shared settings, host overrides, and encrypted secrets

`home/dot_config/noctalia/private_config.toml.tmpl` contains the shared defaults.
It selects files in `home/.chezmoitemplates/noctalia/hosts/` using
`.chezmoi.hostname`:

- `<hostname>.toml`: non-sensitive machine overrides (monitors, widgets, calendar,
  wallpapers, and device preferences).
- `<hostname>.age`: age-encrypted TOML containing the location address and
  Wallhaven API key.

Host overrides take precedence over shared defaults; decrypted secrets take
precedence over both. Theme preferences are shared between the laptop and desktop.
Desktop session shortcuts use `4` for reboot and `5` for shutdown. Host session
action arrays replace the complete shared list, so retain every action when editing them.
Unknown hosts receive shared defaults only. Noctalia's
runtime `settings.toml` is not needed for restoration. The generated
`~/.config/noctalia/config.toml` is owner-readable/writable only.

**Back up `~/.config/chezmoi/age.key` securely outside this repository.** The
private key is required to restore encrypted settings; the public recipients in
`home/.chezmoi.toml.tmpl` cannot decrypt them. The laptop and desktop use separate
keys. Restore the matching machine's key; the laptop key cannot decrypt the
desktop's encrypted settings.

To restore a configured machine:

1. Set the machine's hostname to match its host files (`cachyos-desktop` or `cachyos-laptop`).
2. If that host has encrypted settings, restore the private key to `~/.config/chezmoi/age.key` with permissions `600`.
3. Run `chezmoi init --apply https://github.com/JohWQ/dotfiles.git`. The init
   template configures age automatically.

To refresh only Noctalia on an initialized machine:

```sh
chezmoi apply ~/.config/noctalia/config.toml
noctalia msg config-reload
```

On the desktop, after these repository changes have been committed and pushed,
run `chezmoi update` to pull and apply them, then `noctalia msg config-reload`
if Noctalia is running. The desktop automatically selects its host overrides
and decrypts its secrets using its own age key.

Noctalia loads `~/.local/state/noctalia/settings.toml` after the generated config.
If an old UI setting masks a repository change, remove only the corresponding
override (for example, `[theme]` or `[[shell.session.actions]]`) from that file,
then reload Noctalia. Other runtime settings can be kept.

For another PC, add its own `<hostname>.toml` and, if needed, `<hostname>.age`.
Encrypt a private TOML file with `chezmoi encrypt --output <hostname>.age
/path/to/private-secrets.toml`, and put only the encrypted output in the host
folder. Register a new machine's public recipient in `home/.chezmoi.toml.tmpl`
before encrypting with its key. Devices using encrypted host files need the
matching backed-up private key.
Edit the shared template or host files directly; do not re-add the generated
Noctalia config, which contains decrypted secrets. Runtime settings changes
are not automatically saved back to the repository.

### Potential issues
#### Noctalia settings not applying
Compare the files: `~/.config/noctalia/config.toml` & `~/.local/state/noctalia/settings.toml`
Example command:
`diff ~/.config/noctalia/config.toml ~/.local/state/noctalia/settings.toml`
#### Certain windows spawn too small/large
Take a look at the relevant niri config file: `~/.config/niri/cfg/rules.kdl`
Change the settings that set the window size by pixels.

### References
#### Documentation:
https://www.chezmoi.io/

##### Many aspects of this setup were inspired by:
[hankertrix/Dotfiles](https://github.com/hankertrix/Dotfiles.git)
