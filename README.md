# Dotfiles - managed by chezmoi

Work in progress.

Initialize and apply dotfiles:

```sh
chezmoi init --apply https://github.com/JohWQ/dotfiles.git
```

`chezmoi apply` installs packages from `<chezmoi-source-directory>/package-lists`

The `<chezmoi-source-directory>/root` directory is not tracked by Chezmoi.

### Optional dependencies:
```
# aur packages:
yay -S xdg-desktop-portal-termfilechooser-hunkyburrito-git
# or use shelly:
# shelly xdg-desktop-portal-termfilechooser-hunkyburrito-git 

# org.freedesktop.FileManager1.common (yazi file view):
git clone https://github.com/boydaihungst/org.freedesktop.FileManager1.common
cd org.freedesktop.FileManager1.common
meson setup build --reconfigure
sudo ninja -C build install
```

### References
#### Documentation:
https://www.chezmoi.io/

##### Many aspects of this setup were inspired by:
[hankertrix/Dotfiles](https://github.com/hankertrix/Dotfiles.git)
