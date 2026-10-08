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
| `cachyos-laptop` on Linux | Shared Linux dotfiles; its Noctalia override file is currently empty pending capture from the laptop. |
| `windows-desktop`, or any native Windows system | No dotfiles or installation scripts are applied by default. |

Windows is opt-in: `home/.chezmoiignore` excludes all targets for Windows and
for the `windows-desktop` hostname, including when that hostname is seen from
WSL. Before enabling a Windows application, add its configuration at the
correct Windows destination and explicitly allow that target in the Windows
ignore branch. Merely installing an application does not opt it in. Chezmoi's
own initialization config can still be generated.

The laptop's existing customizations have not been collected. Before its first
apply, compare `chezmoi diff --exclude=scripts` with the local files and capture
its differences. The hostname selection currently applies to Noctalia; other
Linux dotfiles remain shared. Add hostname/OS conditions to those templates as
actual differences are collected. Do not copy desktop monitor layouts or
secrets into the laptop override file.

### Optional dependencies:
```sh
# aur packages:
yay -S xdg-desktop-portal-termfilechooser-hunkyburrito-git biri-git
# or use shelly:
# shelly xdg-desktop-portal-termfilechooser-hunkyburrito-git
# shelly biri-git

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
precedence over both. Unknown hosts receive shared defaults only. Noctalia's
runtime `settings.toml` is not needed for restoration. The generated
`~/.config/noctalia/config.toml` is owner-readable/writable only.

**Back up `~/.config/chezmoi/age.key` securely outside this repository.** The
private key is required to restore encrypted settings; the public recipient in
`home/.chezmoi.toml.tmpl` cannot decrypt them.

To restore a configured machine:

1. Set the machine's hostname to match its host files (`cachyos-desktop` or `cachyos-laptop`).
2. If that host has encrypted settings, restore the private key to `~/.config/chezmoi/age.key` with permissions `600`.
3. Run `chezmoi init --apply https://github.com/JohWQ/dotfiles.git`. The init
   template configures age automatically.

To refresh only Noctalia on an initialized machine:

```sh
chezmoi apply ~/.config/noctalia/config.toml
```

For another PC, add its own `<hostname>.toml` and, if needed, `<hostname>.age`.
Encrypt a private TOML file with `chezmoi encrypt --output <hostname>.age
/path/to/private-secrets.toml`, and put only the encrypted output in the host
folder. Devices using encrypted host files need the backed-up private key.
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
