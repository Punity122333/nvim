# editing/autopairs.lua

Source: `lua/plugins/editing/autopairs.lua`

## Purpose
Provides automatic pair insertion with Treesitter awareness and custom CR behavior.

## Plugins
- `nvim-mini/mini.pairs` (disabled)
- `windwp/nvim-autopairs`

## Configuration
- Treesitter checks enabled for pairing and bracket-line validation.
- `ts_config` marks strings for Lua and Python.
- Maps `<S-CR>` to `nvim-autopairs` CR handling and exposes `_G.smart_autopairs_cr`.
- Adds Lua `endwise` rules via `nvim-autopairs.rules.endwise-lua`.
