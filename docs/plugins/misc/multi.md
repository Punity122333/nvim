# misc/multi.lua

Source: `lua/plugins/misc/multi.lua`

## Purpose
Provides multi-cursor editing with custom navigation and selection keymaps.

## Plugins
- `jake-stewart/multicursor.nvim`
- `mg979/vim-visual-multi` (disabled)

## Configuration
- Multicursor update rate set to 150ms.
- Keymaps:
  - `\\q` toggle cursor, `\\k/j/m` add cursor, `\\n` add match, `\\s` skip match, `\\a` add all, `\\c` clear, `\\w` toggle enable.
  - `H`/`L` switch between prev/next cursor or search result.
- Disables default `n`/`N` to avoid conflicts.
