# tools/dap.lua

Source: `lua/plugins/tools/dap.lua`

## Purpose
Configures DAP UI layout and auto-refresh behavior.

## Plugins
- `rcarriga/nvim-dap-ui`
- `mfussenegger/nvim-dap` (dependency)
- `nvim-neotest/nvim-nio` (dependency)

## Configuration
- Two-pane layout: left (scopes/breakpoints/stacks/watches) and bottom (repl/console).
- Rounded borders for floating windows.
- Auto-refreshes DAP UI on breakpoint and debug events.
- Custom winbar titles and highlight adjustments for DAP UI buffers.
