# tools/otter.lua

Source: `lua/plugins/otter.lua`

## Purpose
Runs the JavaScript that is embedded in HTML templates, so the script blocks of
a template can be linted and completed without leaving the file.

## Plugins
- `jmbuhr/otter.nvim`
- `nvim-treesitter/nvim-treesitter` (dependency)

## Configuration
- `ft = { "html", "htmldjango" }` - only loaded for HTML-ish buffers.
- `lsp.diagnostic_update_events = { "BufWritePost", "InsertLeave" }`.
- `lsp.root_dir` resolves the project root via `vim.fs.root(bufnr, { ".git",
  "package.json" })` and falls back to `vim.fn.getcwd()`.
- `buffers.set_filetype = true`, `buffers.write_to_disk = false` - the
  extracted buffers are never written back to disk.
- `handle_leading_whitespace = true`.
- `verbose.no_code_found = true` - warns when a buffer has no injected code
  chunks; the comment notes this is turned on temporarily to debug.

## Why otter is activated from a `FileType` autocmd
`require("otter").activate({ "javascript" }, true, true)` runs in a `FileType`
autocmd for `html` and `htmldjango`, inside the augroup `otter_embedded_js`.
The two `true` arguments enable completion and diagnostics for the embedded
JavaScript.

## Why otter is only configured here
`jmbuhr/otter.nvim` used to be configured a second time in
`lua/plugins/blink-cmp.lua`. That file is imported *before* `otter.lua`
(alphabetical order), so the copy in `otter.lua` won and the blink.cmp copy
was dead code. It was removed from `blink-cmp.lua`; the blink.cmp `otter`
source was dropped as well, because otter does not register an nvim-cmp source
and the compat bridge could never resolve it.
