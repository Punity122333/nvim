# lsp/inlinediag.lua

Source: `lua/plugins/lsp/inlinediag.lua`

## Purpose
Renders inline diagnostics at end-of-line with cursor-aware updates.

## Plugins
- `rachartier/tiny-inline-diagnostic.nvim`

## Configuration
- Disables default virtual text and enables modern inline preset.
- Multiline diagnostics enabled and always shown; source hidden.
- Custom cursor-line diagnostic extmarks with left/right caps.
- Re-renders on cursor movement, diagnostic changes, and colorscheme changes.
