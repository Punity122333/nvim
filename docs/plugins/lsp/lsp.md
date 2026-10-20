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
- Semantic tokens are disabled for every client:
  - client side: `vim.lsp.semantic_tokens.enable(false)`, so Neovim never requests or renders tokens.
  - server side: `servers["*"].capabilities.textDocument.semanticTokens = vim.NIL` (JSON `null`), so servers that honour the client capability do not advertise `semanticTokensProvider` at all. `false` must not be used here - rust-analyzer aborts the session on a boolean.
- Debounces diagnostics, with a global 800ms timer for `lua_ls` to reduce workspace churn.
- Sets UTF-8 position encoding and enables snippet support for completion items.
- Skips setup for a list of servers (e.g., `copilot`, `rust_analyzer`, `tsserver`).
