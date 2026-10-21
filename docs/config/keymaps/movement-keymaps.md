# keymaps/movement_keymaps.lua

Source: `lua/config/keymaps/movement_keymaps.lua`

## Purpose
Movement keys that are not owned by a plugin.

## Plugins
- `lua/plugins/outline.lua` (the `Outline` command).

## Configuration
| Mode | Key | Action |
| --- | --- | --- |
| `n` | `<leader>O` | open the outline |
| `i` | `<BS>` | `<C-g>u<BS>` - delete the character *and* the undo break |

## Notes
- `<C-h>`/`<C-j>`/`<C-k>`/`<C-l>` (move between windows) used to be mapped
  here **and** in `plugin_keymaps.lua`, and `smart-splits.nvim` maps them as
  well. They are now owned by `smart-splits.nvim` only (see
  `lua/plugins/smart-splits.lua`), which does the same thing.
- The file also contains a large commented-out block: an experimental
  "read the target of a motion" helper. It is kept as a reminder of what was
  tried, it is not used.
