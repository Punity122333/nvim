# config/autocmds.lua

Source: `lua/config/autocmds.lua`

## Purpose
The autocmds of the configuration: the behaviour that is not tied to a single
plugin.

## Plugins
- None directly; the autocmds drive `avante`, `vtsls`, `marks`, `dap` and
  the snacks explorer.

## Configuration
### LSP
- On `LspAttach` the `offset_encoding` of the client is forced to `utf-16`
  (and to `utf-8` for `rust-analyzer`, see below).
- A `CursorHold` autocmd asks the server for the code actions of the
  diagnostics under the cursor. The request is only sent when the
  diagnostics under the cursor actually changed - the answer is thrown away
  anyway, and it used to arrive exactly when the user stopped moving the
  cursor, which is when a repaint is the most noticeable. `html`, `cssls`,
  `eslint` and `crates.nvim` are excluded.
- For `rust-analyzer` the `offset_encoding` is `utf-8` instead: the config
  forces utf-8 for that client (the standard library sources are read from
  disk), so the client has to agree.
- For `taplo` (on `Cargo.toml`) the `hoverProvider` capability is removed.
- On `FileType` for the JavaScript/TypeScript filetypes `lsp enable vtsls`
  is run.

### Tree-sitter
- The buffer is parsed right after it was read (`BufReadPost`/`BufNewFile`),
  so that the folds and the indent have their tree before the first key
  press. The parse is *synchronous* and therefore skipped for buffers with
  more than 1000 lines.

### Signs and marks
- `m` + a letter sets a mark and redraws the signs.
- The DAP signs are defined (`DapBreakpoint`, `DapStopped`, ...).
- The diagnostic signs get priority 20, the marks signs priority 30.
- `WinScrolled` autocmds are cleared (`vim.api.nvim_clear_autocmds`).

### Filetypes
- `avante`/`avante-input`: `conceallevel` is lowered to 2 and the buffer
  stays modifiable.
- `Avante`: blink.cmp is disabled (the completions come from Avante).
- `spectre_panel`: no line numbers.
- `dbui`: the window is moved to the left and resized to 40 columns.
- `cpp`: a redraw is scheduled (the C++ syntax is only correct after one).
- `c`, `cpp`, `h`, `hpp`: `cindent` and `smartindent` are off, `autoindent`
  is on and the hybrid `indentexpr` is installed (see `cpp-indent.md`).
- `TermOpen`: no line numbers.

### Misc
- When a buffer is deleted, Avante is refreshed.
- On `DiagnosticChanged` the snacks explorer is refreshed, but not more than
  once every 800ms.
- On `FocusGained` the Lua garbage collector runs (1s later).
- Buffers with more than 5000 lines do not get auto-formatted on save.

## Why the C++ redraw is scheduled
The `FileType` event also fires for the *temporary* buffers that Neovim uses
to evaluate a filetype option (`vim.filetype.get_option()`). Those buffers
are already gone when the callback runs, so the callback must not touch the
buffer. The redraw is scheduled because doing it in the middle of the event
paints a half-finished screen - the old cursor cell stays visible for a
moment (the "ghosting" of the cursor).

## The removed `a<Esc>` hack
There used to be an autocmd that entered insert mode and left it again right
after a file was opened, to "prime" the buffer. It was removed because
`nvim_feedkeys()` puts the keys into the *typeahead*: a fast `gcc` was
split into `g` + `a<Esc>` + `cc`, so the comment never happened and the
leftover `cc` changed the line. The insert-mode round trip also changed the
cursor shape on every file open, which was most of the reported "ghosting".

## The bold cursor character
`CursorBoldChar` draws the character under the cursor in bold, but it is
**off by default** (`vim.g.cursor_bold_char = true` enables it): it repaints
the cell under the cursor *after* the cursor has already moved on, and the
terminal restores its cached copy of that cell when the cursor leaves - the
stale content showed up as a ghost of the old cursor position.
