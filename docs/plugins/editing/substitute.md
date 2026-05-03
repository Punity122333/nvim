# editing/substitute.lua

Source: `lua/plugins/editing/substitute.lua`

## Purpose
Provides operator and line-based substitution commands.

## Plugins
- `gbprod/substitute.nvim`

## Configuration
- Enabled on `BufReadPost` and `BufNewFile`.
- Highlight substituted text for 100ms.
- Keymaps:
  - `gl` (operator and visual)
  - `gll` (line)
  - `gL` (to end of line)
