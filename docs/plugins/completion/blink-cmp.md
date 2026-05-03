# completion/blink-cmp.lua

Source: `lua/plugins/completion/blink-cmp.lua`

## Purpose
Completion engine configuration with custom snippet expansion and smart accept behavior.

## Plugins
- `saghen/blink.cmp`
- `rafamadriz/friendly-snippets` (dependency)

## Configuration
- Uses `modules.completion.engine` for snippet expansion and jumping.
- Completion UI: rounded borders, no scrollbar, auto-show docs.
- Ghost text disabled; signature help disabled.
- Custom accept logic inserts missing closing parens and positions cursor inside calls.
- Keymaps for navigation (`<C-n>`, `<C-p>`, `<C-j>`, `<C-k>`), accept (`<S-CR>`, `<A-CR>`, `<C-y>`, `<C-CR>`), and snippet jumps (`<Tab>`, `<S-Tab>`).
- Sources: `snippets`, `lsp`, `path`, `buffer`, plus `emoji` via `blink.compat.source`.
- Snippets search path includes `~/.config/nvim/snippets` and friendly-snippets.
