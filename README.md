# Dotfiles

Personal configs managed with [chezmoi](https://www.chezmoi.io/).
See [AGENTS.md](AGENTS.md) for repository editing and validation guidelines.

## Restore

On Linux, set the hostname and restore its age key to
`~/.config/chezmoi/age.key` (permissions `600`):

```sh
chezmoi init https://github.com/JohWQ/dotfiles.git
chezmoi diff --exclude=scripts
chezmoi apply
```

Update with `chezmoi update`. Linux apply scripts install packages.
Back up each host's age key separately, outside this repository.

| Host | Configuration |
| --- | --- |
| `cachyos-desktop` | Umbriel, Noctalia and Linux apps; desktop overrides. |
| `cachyos-laptop` | Umbriel, Noctalia and Linux apps; laptop overrides. |
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

Desktop and laptop share behavior, with host-specific displays and window sizes.
Validate `~/.config/umbriel/config.toml` with `umbriel config validate`.

Install `umbriel-move-window` and `umbriel-maximize` separately. OCR needs grim,
slurp, Tesseract (English and Norwegian), and wl-clipboard; drawing needs
wayscriber and its user service.

### Niri

Requires [`biri-git`](https://github.com/barrulus/biri#fork-features) for sticky
floating windows. Install scratchpad support with hidden workspaces:

```sh
cargo install --git https://github.com/argosnothing/niri-scratchpad-rs.git --branch=hidden-workspaces
```

### Noctalia

Bar layout and widget actions are shared; host overrides supply display settings,
preferences and encrypted secrets. Refresh config and plugins with:

```sh
chezmoi apply ~/.config/noctalia/config.toml ~/restore-noctalia-plugins.sh
```

This clears selected runtime overrides and reloads Noctalia. Check plugins with
`noctalia msg plugins list`.

### Yazi

Run `ya pkg install` to restore pinned plugins and flavors.

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
