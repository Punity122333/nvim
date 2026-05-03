# editing/yanky.lua

Source: `lua/plugins/editing/yanky.lua`

## Purpose
Improves yank/paste history with a ring and highlight feedback.

## Plugins
- `gbprod/yanky.nvim`
- `kkharji/sqlite.lua` (dependency)

## Configuration
- History length 100 stored in shada.
- Highlight on yank/put with 200ms timer.
- Preserves cursor position after yank.
- Disables default `p` and `P` mappings to avoid conflicts.
