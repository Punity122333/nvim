# editing/surround.lua

Source: `lua/plugins/editing/surround.lua`

## Purpose
Provides surround add/delete/replace actions with custom mappings.

## Plugins
- `nvim-mini/mini.surround` (disabled)
- `kylechui/nvim-surround`

## Configuration
- Disables default insert/normal/visual mappings from `nvim-surround`.
- Custom mappings:
  - Normal: `gsa` add, `gsd` delete, `gsr` replace, `gss` surround line.
  - Visual: `gs` surround selection.
- `move_cursor = false` in setup.
