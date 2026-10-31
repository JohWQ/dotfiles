# Dotfiles - managed by chezmoi

Work in progress.

For contribution, validation, and configuration-capture instructions, see
[AGENTS.md](AGENTS.md).

Initialize and apply dotfiles on Linux (review the host policy below first):
```sh
chezmoi init --apply https://github.com/JohWQ/dotfiles.git
```

Update dotfiles:
```sh
chezmoi update
```

Yazi configuration and `package.toml` are tracked, along with the custom
`confirm-quit.yazi` plugin. Downloaded plugins and flavors are excluded from both
Git and chezmoi; `ya pkg install` restores the versions pinned in `package.toml`.
After intentionally upgrading packages with `ya pkg upgrade`, review and save
the new pins with `chezmoi re-add ~/.config/yazi/package.toml`.
Avoid re-adding downloaded plugin files themselves.

On Linux, `chezmoi apply` installs packages defined in
`<chezmoi-source-directory>/run_onchange_before_install-...-packages.sh.tmpl`.
On `windows-desktop`, UniGetUI manages system packages and their cloud backup;
chezmoi restores application configs and pinned Yazi plugins.

The `<chezmoi-source-directory>/root` directory is not tracked by Chezmoi.

### Host and operating-system policy

| System | Restore behavior |
| --- | --- |
| `cachyos-desktop` on Linux | Shared Linux dotfiles plus desktop Noctalia overrides and encrypted secrets. |
| `cachyos-laptop` on Linux | Shared Linux dotfiles plus laptop Noctalia overrides and encrypted location settings. |
| Native Windows host `windows-desktop` | UniGetUI manages system packages. Chezmoi restores Windows Neovim, Yazi, and PowerShell 7 configs, plus pinned Yazi plugins. Linux dotfiles and installation scripts are excluded. |
| Other native Windows hosts, or WSL named `windows-desktop` | No dotfiles or installation scripts are applied by default. |

Windows uses independent application configs rather than the Linux Neovim and
Yazi files. On native `windows-desktop`, `home/.chezmoiignore` allows only these
source locations (the `readonly_` prefix preserves the existing Windows directory attribute):

| Application | Separate chezmoi source location |
| --- | --- |
| Neovim | `home/readonly_AppData/Local/nvim/` |
| Yazi | `home/readonly_AppData/Roaming/yazi/config/` |
| PowerShell 7 | `home/readonly_Documents/PowerShell/` |
| Windows PowerShell 5.1 | `home/Documents/WindowsPowerShell/` (allowed, no profile captured) |

The Windows configs preserve this host's Neovim settings and plugin lockfiles,
Yazi openers, keymaps and bookmarks configured in `init.lua`, and PowerShell 7
aliases, Starship, zoxide, and the Yazi directory-changing wrapper. The separate
Neovim checkout's `.git` directory is excluded.

PowerShell caches Starship's generated initialization script under
`%LOCALAPPDATA%\PowerShell\Cache\starship-init`; the first launch builds the cache,
and executable changes refresh it automatically. Yazi opens Neovim in a new
instance directly through Windows, avoiding an extra PowerShell startup.

Neovim's `<leader>op` uses native Windows PowerShell for clipboard images;
Linux uses Obsidian's Wayland/X11 clipboard provider. `<leader>ui` opens images
in the system viewer when the terminal cannot render them. Windows uses native
split navigation; Linux enables tmux integration only inside a tmux session.

UniGetUI's GitHub cloud backup is the package inventory for `windows-desktop`.
Keep package installation, updates, and removal in UniGetUI. Chezmoi does not
maintain a second Windows package list or manage UniGetUI's login, settings,
cache, or backup files.

To restore native `windows-desktop`:

1. Install [UniGetUI](https://github.com/Devolutions/UniGetUI#installation),
   using its installer or this bootstrap command:

   ```powershell
   winget install --exact --id Devolutions.UniGetUI --source winget
   ```

2. Sign in to UniGetUI with the same GitHub account. In **Package backup
   settings**, choose **Select backup** and open the `WINDOWS-DESKTOP\<username>`
   backup. Restore it before enabling automatic cloud backups on a fresh
   installation with the same hostname and username, to preserve the old list.
3. On the **Package Bundles** page, review the packages and choose **Install
   selection**. Set up required package managers and sources first; packages
   marked Unknown may require manual installation. Ensure chezmoi, Git,
   PowerShell 7, Neovim, Yazi, Starship, and zoxide are installed through UniGetUI.
4. Open a new PowerShell 7 session so installed tools are on `PATH`, then restore
   the dotfiles:

   ```powershell
   chezmoi init https://github.com/JohWQ/dotfiles.git
   chezmoi diff --exclude=scripts
   chezmoi apply
   . $PROFILE
   ```

Cloud backup stores the package list and install options; application configs
are restored separately by chezmoi. See the
[cloud backup guide](https://www.marticliment.com/unigetui/help/cloud-backup-overview/).

Install the additional tools used by individual shortcuts through UniGetUI as
needed (`fd`, `ripgrep`, `fastfetch`, and `fzf`); enable Windows OpenSSH if needed.
Windows initialization selects Neovim as the editor and PowerShell 7 for
`chezmoi cd`; it does not require Linux age
keys. The Windows Yazi script installs the versions pinned in its own
`package.toml` after configuration files are applied, and reruns when that list
changes. It fails visibly if Yazi is missing or installation fails; rerun
`chezmoi apply` after resolving the issue.

Downloaded Yazi plugins and flavors are excluded from Git. Only the local
`confirm-quit.yazi/main.lua` is captured alongside `package.toml`. Runtime
bookmarks, Yazi state, PowerShell modules, and the copied `dot_zshrc` reference
are not managed. Neovim's plugin manager restores its plugins on first launch.

Other Windows hosts and WSL named `windows-desktop` remain excluded. Windows
application paths are also excluded on Linux. Chezmoi's initialization config
can still be generated.

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
Session actions are shared across Linux hosts: Lock & Suspend uses shortcut `3`,
Reboot uses `4`, Shutdown uses `5`, and Reboot to UEFI is enabled. Plain Suspend
and the custom Sunshine suspend action are disabled, matching the GUI selection.
Locking before suspend is enabled on every host. Edit these settings in the
shared template rather than adding host action arrays.
Unknown hosts receive shared defaults only. Noctalia's
runtime `settings.toml` is not needed for restoration. The generated
`~/.config/noctalia/config.toml` is owner-readable/writable only.

The shared config enables the installed plugins on Linux hosts:

- Official: Screen Recorder, Wallhaven, and Bitwarden.
- Community: Calculator, Phone Connect, Pomodoro, Syncthing, Default Apps,
  and Shelly.

Their IDs, settings, and official/community Git sources are declared in the
shared template. Noctalia fetches enabled plugins from those sources and keeps
them updated (`auto_update = "all"`); Git and network access are required for
downloads. Downloaded plugin
code and runtime state are excluded from chezmoi and Git. Windows installs
exclude the Noctalia config along with the other Linux dotfiles.

The `restore-noctalia-plugins` apply script reruns when the generated Noctalia
config changes. It removes stale `[plugins].enabled`, `[bar.default].end`,
`[shell.session].actions`, `[lockscreen].lock_before_suspend`, and login-box
`show_media` overrides
from `~/.local/state/noctalia/settings.toml`, keeping other runtime
settings, then reloads Noctalia and enables the configured plugins when running.
This lets the shared plugin list
and host bar layout take effect, including Shelly on the laptop. When Noctalia
is stopped, plugins are restored on its next startup. Check activation with
`noctalia msg plugins list`. Shelly also requires the `shelly` application on PATH
and hides its widget when there are no updates with the shared settings.

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
chezmoi apply ~/.config/noctalia/config.toml ~/restore-noctalia-plugins.sh
```

On the desktop, after these repository changes have been committed and pushed,
run `chezmoi update` to pull and apply them. The restore script reloads Noctalia
if it is running. The desktop automatically selects its host overrides
and decrypts its secrets using its own age key.

Noctalia loads `~/.local/state/noctalia/settings.toml` after the generated config.
If an old UI setting masks a repository change, remove only the corresponding
override (for example, `[theme]`) from that file,
then reload Noctalia. Other runtime settings can be kept.

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
