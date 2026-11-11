# Repository Guidelines

## Project Structure

`.chezmoiroot` selects `home/` as the source root. Linux configs live in
`home/dot_config/`; Windows configs use `home/readonly_AppData/` and
`home/readonly_Documents/`. Installation scripts live in
`home/.chezmoiscripts/`. Host overrides live in
`home/.chezmoitemplates/<app>/hosts/`. `home/.chezmoidata.toml` defines host
groups. `package-lists/` contains Linux package inventories. `root/` holds system configuration references outside chezmoi's
managed home. Themes and application assets stay beside their configs.

## Development and Validation

There is no build step, central test suite, or coverage requirement. Validate
changes on the affected OS and hostname:

- `chezmoi managed --include=scripts`: inspect enabled installation scripts.
- `chezmoi diff --exclude=scripts`: review generated configuration changes.
- `chezmoi apply --dry-run`: preview the complete apply operation.
- `git diff --check`: detect whitespace errors.
- `chezmoi apply`: apply reviewed changes; scripts may install packages.

Smoke-test affected applications after applying. Check host selection when
editing templates or ignore rules. Native `windows-desktop` uses UniGetUI and
its GitHub cloud backup for system packages; chezmoi restores configs and Yazi
plugins. Keep Linux installation scripts excluded there.

## Style and Naming

Preserve each file's existing formatting and chezmoi attributes: `dot_`,
`private_`, `readonly_`, `executable_`, and `.tmpl`. Installation scripts in
`home/.chezmoiscripts/` follow `run_onchange_before_…` or
`run_onchange_after_…` naming; their targets are `.chezmoiscripts/<name>`, which
is also the path `.chezmoiignore` uses. Neovim's
`dot_stylua.toml` specifies two spaces, Unix line endings, and a 160-column
width; use it when running StyLua on those Lua files.

Do not repeat hostname lists in templates or `.chezmoiignore`. Add the host to
a group in `home/.chezmoidata.toml` and test it with
`has .chezmoi.hostname .hosts.<group>`. `home/.chezmoi.toml.tmpl` cannot read
that data, so age recipients stay keyed by hostname there.

Prefer `~/…` where supported. Generate required absolute paths in templates
with `.chezmoi.homeDir` and `joinPath`.

## Capturing Configuration and Secrets

Capture Windows edits with `chezmoi add $PROFILE` or
`chezmoi add "$env:LOCALAPPDATA/nvim/init.lua"`. Verify actual application paths;
redirected Documents/AppData require matching source paths and ignore exceptions.

Windows Neovim files that are identical to Linux are one-line `.tmpl` stubs in
`home/readonly_AppData/Local/nvim/` that `include` the file under
`home/dot_config/nvim/`; edit the Linux file to change both. Do not
`chezmoi add` those targets on Windows. To diverge a file on Windows, replace its stub
with a real copy; to share one, replace the copy with a stub. `init.lua`,
`lazy-lock.json`, `lua/custom/clipboard.lua`, `lua/custom/plugins/init.lua` and
`lua/kickstart/health.lua` are separate per OS. Yazi configs are fully separate.

For new Noctalia hosts, add `<hostname>.toml` and optional `<hostname>.age` in
the host directory. Register the public recipient in `home/.chezmoi.toml.tmpl`
before encrypting private TOML with `chezmoi encrypt --output <hostname>.age
/path/to/private-secrets.toml`. Keep private keys outside Git. Edit source
templates or overrides directly; never re-add generated Noctalia config
containing decrypted secrets. Exclude credentials, downloaded plugins, and
runtime state.

## Application Configuration

Umbriel shared behavior and shortcuts live in
`home/dot_config/umbriel/config.toml.tmpl`, including window sizes and
positions, which assume 1920x1080 outputs. Host files in
`home/.chezmoitemplates/umbriel/hosts/<hostname>.toml` contain only outputs and
output routing; they are appended, so a host rule with the same `match` can
override a shared size. Scratchpad terminals are launched with an app_id
ending in `Scratchpad` (`--class <Name>Scratchpad`); one shared rule matching
`Scratchpad$` sizes them like a default column, as a fraction of the output's
usable area so it also fits the resizable Sunshine output `HDMI-A-1`. Kitty scratchpads also pass
`-o remember_window_size=no` so Kitty does not restore its own cached size. Capture local edits in the appropriate source;
`chezmoi add` would replace the template with one machine's generated config.
Validate generated configs with `umbriel config validate`.

Sunshine streams to `HDMI-A-1`, whose logical size follows the client. Rules
for windows that must fit there use `default_floating_size` fractions, not
pixels.

Noctalia defaults live in `home/dot_config/noctalia/private_config.toml.tmpl`.
Desktop and laptop share the bar layout and Umbriel widget actions through
`home/.chezmoitemplates/noctalia/umbriel.toml`. Host TOML overrides provide
displays, wallpapers, plugins and preferences; encrypted host overrides apply
last. Unknown hosts use shared defaults. Validate with `noctalia config validate`.
If settings do not apply, compare the generated config with
`~/.local/state/noctalia/settings.toml`: runtime overrides take precedence.
`noctalia-diff` (alias `noctdiff`) lists the runtime keys that differ from or
are missing in the deployed config; merge those into the shared, Umbriel or
host source. The restore script clears selected managed overrides and reloads
Noctalia.

Niri remains the fallback session (`biri-git`); its config is still managed.
Niri settings marked `// biri-git (niri fork) feature(s):` depend on the fork;
remove or adapt them when targeting upstream Niri.

Yazi plugins and flavors are pinned in `package.toml`; only the local
`confirm-quit.yazi` plugin is stored in Git. The install scripts ask, when run
interactively, whether to pass `--discard` to `ya pkg install`; it overwrites
locally edited packages. After an intentional `ya pkg upgrade`,
capture pins with `chezmoi re-add ~/.config/yazi/package.toml`.

## Commits and Pull Requests

History uses short descriptive subjects such as `Restore Noctalia settings by
host with age-encrypted secrets`; no mandatory prefix is established. Prefer
specific subjects over `misc`. Keep changes focused. PRs should describe affected
hosts, resulting behavior, validation performed, and any package or secret
requirements. Link relevant issues and include screenshots for visual changes.
