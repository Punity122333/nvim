# lsp/rustaceanvim.lua

Source: `lua/plugins/rustaceanvim.lua`

## Purpose
Rust-specific LSP integration with rust-analyzer tuning.

## Plugins
- `mrcjkb/rustaceanvim`

## Configuration
- Uses `blink.cmp` capabilities when available.
- Disables semantic tokens (`capabilities.textDocument.semanticTokens = vim.NIL`, plus dropping `semanticTokensProvider` on attach) and debounces flyCheck on cursor idle.
- The flyCheck debounce is **1200ms**: `CursorMoved`, `CursorMovedI` and `TextChangedI` restart a timer, and only when it expires `RustLsp flyCheck run` is sent. `checkOnSave = false` in the server settings, so this is the only thing that produces diagnostics.
- rust-analyzer settings: threads, cache priming, cargo/build scripts, proc macros, completion tuning.
- Refreshes `snacks` explorer after flyCheck if available.

## Why `opts` and not `config`
The spec used to use a `config` function. A user `config` *replaces* the one from the LazyVim `lang.rust` extra, which silently dropped the extra's codelldb DAP adapter and its `<leader>cR` / `<leader>dr` mappings. Using `opts` merges with the extra and keeps its `config` running.

## The capabilities
The capabilities are built from scratch here (because blink's are needed), so the global `servers["*"]` opt-out of the semantic tokens does not apply to rust-analyzer on its own. They are registered twice: once in `opts.server.capabilities` and once in `vim.lsp.config["rust-analyzer"]`, because rustaceanvim merges `vim.lsp.config["rust-analyzer"]` *over* its own server config - otherwise the global capabilities would replace blink's.

The utf-8 position encoding is advertised first, because `config/autocmds.lua` forces `utf-8` for rust-analyzer: the server picks the first encoding it supports out of `capabilities.general.positionEncodings`, and that is what ends up in `client.offset_encoding`.
