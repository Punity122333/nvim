# ui/noice.lua

Source: `lua/plugins/ui/noice.lua`

## Purpose
Custom LSP hover/signature UI with manual focus/close behavior.

## Plugins
- `folke/noice.nvim`

## Configuration
- Noice popup borders are rounded; LSP progress disabled.
- Signature help enabled but auto-open disabled.
- Filters a list of noisy messages via routes.
- Custom hover/signature popup that toggles, focuses, or closes via `<C-;>`.
- Force-close mappings: `<C-S-;>` and `<A-;>`.
- Auto-dismisses signature popups when leaving a function call.
