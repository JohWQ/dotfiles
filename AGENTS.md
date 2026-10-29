# Repository Guidelines

## Project Structure

`.chezmoiroot` selects `home/` as the source root. Linux configs live in
`home/dot_config/`; Windows configs use `home/readonly_AppData/` and
`home/readonly_Documents/`. Noctalia host overrides live in
`home/.chezmoitemplates/noctalia/hosts/`. `package-lists/` contains Linux package
inventories. `root/` holds system configuration references outside chezmoi's
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
`private_`, `readonly_`, `executable_`, and `.tmpl`. Installation scripts follow
`run_onchange_before_…` or `run_onchange_after_…` naming. Neovim's
`dot_stylua.toml` specifies two spaces, Unix line endings, and a 160-column
width; use it when running StyLua on those Lua files.

Prefer `~/…` where supported. Generate required absolute paths in templates
with `.chezmoi.homeDir` and `joinPath`.

## Capturing Configuration and Secrets

Capture Windows edits with `chezmoi add $PROFILE` or
`chezmoi add "$env:LOCALAPPDATA/nvim/init.lua"`. Verify actual application paths;
redirected Documents/AppData require matching source paths and ignore exceptions.

For new Noctalia hosts, add `<hostname>.toml` and optional `<hostname>.age` in
the host directory. Register the public recipient in `home/.chezmoi.toml.tmpl`
before encrypting private TOML with `chezmoi encrypt --output <hostname>.age
/path/to/private-secrets.toml`. Keep private keys outside Git. Edit source
templates or overrides directly; never re-add generated Noctalia config
containing decrypted secrets. Exclude credentials, downloaded plugins, and
runtime state.

## Commits and Pull Requests

History uses short descriptive subjects such as `Restore Noctalia settings by
host with age-encrypted secrets`; no mandatory prefix is established. Prefer
specific subjects over `misc`. Keep changes focused. PRs should describe affected
hosts, resulting behavior, validation performed, and any package or secret
requirements. Link relevant issues and include screenshots for visual changes.
