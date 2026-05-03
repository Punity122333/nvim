# ui/ui.lua

Source: `lua/plugins/ui/ui.lua`

## Purpose
Aggregates UI-focused overrides for LazyVim, Tokyonight, Which-key, Render Markdown, and Avante.

## Plugins
- `LazyVim/LazyVim`
- `folke/tokyonight.nvim`
- `folke/which-key.nvim`
- `MeanderingProgrammer/render-markdown.nvim`
- `yetone/avante.nvim`

## Configuration
- Sets LazyVim colorscheme to Tokyonight.
- Tokyonight highlights: SignColumn/LineNr/StatusLine/EndOfBuffer backgrounds cleared.
- Which-key delay shortened with smaller window height.
- Render-markdown excludes Avante buffers.
- Avante: stops Treesitter in `Avante` and `AvanteInput` filetypes.
