# Dotfiles

Personal configs managed with [chezmoi](https://www.chezmoi.io/).

## Restore

On Linux, set the hostname and restore its age key to
`~/.config/chezmoi/age.key` (permissions `600`):

```sh
chezmoi init https://github.com/JohWQ/dotfiles.git
chezmoi diff --exclude=scripts
chezmoi apply
```

Update with `chezmoi update`. On Linux, apply also installs the packages in
`package-lists/` and the pinned Yazi plugins. Back up each host's age key
outside this repository.

| Host | Configuration |
| --- | --- |
| `cachyos-desktop` | Umbriel, Noctalia and Linux apps; Sunshine and nvibrant. |
| `cachyos-laptop` | Umbriel, Noctalia and Linux apps. |
| other Linux hosts | Umbriel, Noctalia and Linux apps with shared defaults; no outputs or secrets. |
| `windows-desktop` | Neovim, Yazi and PowerShell 7; UniGetUI packages. |

### Windows

Install UniGetUI:

```powershell
winget install --exact --id Devolutions.UniGetUI --source winget
```

Sign in to its GitHub cloud backup and restore `WINDOWS-DESKTOP\<username>`
from **Package Bundles** before enabling automatic backups. Include chezmoi,
Git, PowerShell 7, Neovim, Yazi, Starship and zoxide. In PowerShell 7, run the
restore commands above, then `. $PROFILE`.

## Configuration

### Umbriel

The main session. All Linux hosts share behavior and fractional window sizes;
outputs are per known host, and `cachyos-desktop` overrides the widths with
fixed pixels for its portrait monitor. Validate with `umbriel config validate`.
Apply builds the `umbriel-maximize` and `umbriel-move-window` keybind helpers
from `~/.local/src` with Cargo.

### Noctalia

Bar layout and widget actions are shared; host overrides supply displays,
preferences and encrypted secrets. Refresh config and plugins with:

```sh
chezmoi apply ~/.config/noctalia/config.toml ~/.chezmoiscripts/restore-noctalia-plugins.sh
```

This clears selected runtime overrides and reloads Noctalia. List settings that
drifted from the deployed config with `noctalia-diff`.

### Niri

The fallback session. Requires
[`biri-git`](https://github.com/barrulus/biri#fork-features) for sticky floating
windows, and niri-scratchpad-rs for scratchpads:

```sh
yay -S biri-git
cargo install --git https://github.com/argosnothing/niri-scratchpad-rs.git --branch=hidden-workspaces
```

### Yazi

Plugins and flavors are pinned in `package.toml` and restored on apply; run
`ya pkg install` to restore them manually. The file-view integration needs:

```sh
yay -S xdg-desktop-portal-termfilechooser-hunkyburrito-git

git clone https://github.com/boydaihungst/org.freedesktop.FileManager1.common
cd org.freedesktop.FileManager1.common
meson setup build --reconfigure
sudo ninja -C build install
```

### nvibrant (`cachyos-desktop`)

`nvibrant.service` sets temporal dithering on `DP-1`, which stops the shimmer
that `noctalia msg nightlight-enable` causes.

```sh
yay -S nvibrant-bin
systemctl --user enable --now nvibrant.service
```


Inspired by [hankertrix/Dotfiles](https://github.com/hankertrix/Dotfiles) & more.
