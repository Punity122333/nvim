# lsp/lsp.lua

Source: `lua/plugins/lsp.lua`

## Purpose
Configures `nvim-lspconfig` with diagnostics, server definitions, and LSP performance tweaks.

## Plugins
- `neovim/nvim-lspconfig`
- `3rd/image.nvim` (conditional; disabled in Kitty scrollback)

## Configuration
- Diagnostics: rounded floating borders, severity sorting, virtual text with `●`, no updates in insert.
- The servers that are configured: `vtsls`, `basedpyright`, `lua_ls`, `clangd`, `asm_lsp`, `arduino_language_server`, `omnisharp`, `glsl_analyzer`, `cssls`, `html`, `marksman` and `rust_analyzer` (the last one is only listed so that mason installs the binary - rust-analyzer itself is started by rustaceanvim).
- The servers that are explicitly disabled: `tsserver`, `ts_ls`, `ruff`, `ruff_lsp`, `pyright` and `r_language_server` - the python/R extras enable a competing server by default.
- Inlay hints are disabled for every language (`inlay_hints.enabled = false`), so no server can request them.
- Semantic tokens are disabled for every client:
  - client side: `vim.lsp.semantic_tokens.enable(false)`, so Neovim never requests or renders tokens.
  - server side: `servers["*"].capabilities.textDocument.semanticTokens = vim.NIL` (JSON `null`), so servers that honour the client capability do not advertise `semanticTokensProvider` at all. `false` must not be used here - rust-analyzer aborts the session on a boolean.
- Debounces diagnostics, with a global 800ms timer for `lua_ls` to reduce workspace churn.
- Debounces *pull* diagnostics for `basedpyright` by 1200ms:
  - basedpyright uses the pull model (`textDocument/diagnostic`), and Neovim pulls on every `didChange`, so the type checker re-analysed the file on every keystroke (twice, because basedpyright also answers with `workspace/diagnostic/refresh`).
  - `vim.lsp.diagnostic._refresh` is wrapped so that the request is postponed until the file has been quiet for 1200ms - the same interval the rust-analyzer flyCheck uses in `lsp/rustaceanvim.lua`. The delays live in the `PULL_DEBOUNCE_MS` table, so more servers can be added.
- The position encoding is `utf-16` for every client (`config/autocmds.lua` forces it) and `utf-8` for rust-analyzer.
- `setup.rust_analyzer` returns `true`, so that lspconfig does not start a second, conflicting client.

## Why there is no `config` function
In lazy.nvim a user `config` *replaces* the one of the LazyVim extra. LazyVim's nvim-lspconfig `config` is what wires up mason-lspconfig, the global capabilities, the LSP keymaps and the formatter registration - overriding it silently killed all of that. Everything here is therefore expressed as `opts.servers` entries only, and the diagnostic debounce lives in `init` (which runs *in addition to* the LazyVim `config`).
