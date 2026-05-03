# lsp/lsp.lua

Source: `lua/plugins/lsp/lsp.lua`

## Purpose
Configures `nvim-lspconfig` with diagnostics, server definitions, and LSP performance tweaks.

## Plugins
- `neovim/nvim-lspconfig`
- `3rd/image.nvim` (conditional; disabled in Kitty scrollback)

## Configuration
- Diagnostics: rounded floating borders, severity sorting, virtual text with `●`, no updates in insert.
- Server configs include: `vtsls`, `basedpyright` (custom cmd), `marksman`, `asm_lsp`, `clangd`, `lua_ls`, `omnisharp`, `glsl_analyzer`, `cssls`, `html`, `pasls`.
- On `LspAttach`, semantic tokens are disabled for attached clients.
- Debounces diagnostics, with a global 800ms timer for `lua_ls` to reduce workspace churn.
- Sets UTF-8 position encoding and enables snippet support for completion items.
- Skips setup for a list of servers (e.g., `copilot`, `rust_analyzer`, `tsserver`).
