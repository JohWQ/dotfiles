# Dotfiles - managed by chezmoi

Work in progress.

Initialize and apply dotfiles:
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
