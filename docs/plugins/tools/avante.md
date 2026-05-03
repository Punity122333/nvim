# tools/avante.lua

Source: `lua/plugins/tools/avante.lua`

## Purpose
AI assistant integration with agentic mode and Gemini provider.

## Plugins
- `yetone/avante.nvim`
- Dependencies: `nvim-treesitter`, `dressing.nvim`, `plenary.nvim`, `nui.nvim`, `nvim-web-devicons`, `copilot.lua`, `render-markdown.nvim`.

## Configuration
- Provider: `gemini`, instructions file `avante.md`, input provider `snacks`.
- Keymaps: `<leader>aa` ask, `<leader>ae` edit, `<leader>ar` refresh, `<leader>af` focus, `<leader>at` toggle.
- UI: right sidebar, width 23, rounded borders.
- Suggestions: throttled and disabled when offline (checks `https://1.1.1.1`).
- Auto-suggestions disabled; diff auto-apply disabled.
