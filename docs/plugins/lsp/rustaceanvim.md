# lsp/rustaceanvim.lua

Source: `lua/plugins/lsp/rustaceanvim.lua`

## Purpose
Rust-specific LSP integration with rust-analyzer tuning.

## Plugins
- `mrcjkb/rustaceanvim`

## Configuration
- Uses `blink.cmp` capabilities when available.
- Disables semantic tokens (`capabilities.textDocument.semanticTokens = vim.NIL`, plus dropping `semanticTokensProvider` on attach) and debounces flyCheck on cursor idle.
- rust-analyzer settings: threads, cache priming, cargo/build scripts, proc macros, completion tuning.
- Refreshes `snacks` explorer after flyCheck if available.
