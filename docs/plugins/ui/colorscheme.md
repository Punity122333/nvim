# ui/colorscheme.lua

Source: `lua/plugins/ui/colorscheme.lua`

## Purpose
Configures the Tokyonight colorscheme with UI-specific highlight tweaks.

## Plugins
- `folke/tokyonight.nvim`

## Configuration
- Style: `night`, no transparency, no dim-inactive.
- Sets `bg_statusline` to `#16161e`.
- Forces solid backgrounds for Normal/Float and Telescope UI.
- Adjusts variable and LSP variable colors to light blue.
- Sets custom float border/title and BufferLine separator colors.
