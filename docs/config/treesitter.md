# config/treesitter.lua

Source: `lua/config/treesitter.lua`

## Purpose
The single owner of the rules that decide where the tree-sitter highlighter
is **not** started.

## Plugins
- `nvim-treesitter/nvim-treesitter` (the rules are handed to it, see
  `lua/plugins/treesitter.lua`).

## Configuration
### Languages
`M.disable_langs` is never highlighted:
`diff`, `gitcommit`, `markdown`, `markdown_inline`, `vimdoc`.

### Filetypes
`alpha`, `avante`, `avante-input`, `dashboard`, `gitcommit`, `help`,
`markdown`, `oil`, `TelescopePrompt`, `NvimTree`.

Most of them have no parser at all, so the list is mostly documentation - but
it also keeps the `snacks_*` buffers, which have their own syntax files,
from being touched.

### Size limits
- C/C++ files with more than **1000 lines** are not highlighted (the parse
  is slow and a file that big is not read anyway).
- Files bigger than **100 KiB** are not highlighted either. The answer is
  cached per file name, because the size of a buffer does not change while
  it is open and `fs_stat` is a syscall.

### Diffs
A buffer that is shown in a diff window is never highlighted ('diff' is a
*window* option, so every window that shows the buffer has to be checked).

## How it is applied
The current nvim-treesitter only knows `opts.highlight.disable`, and that
option is a *list of languages* - the old `disable = function(lang, buf)` is
gone. The rules that depend on the buffer itself (its size, whether it is a
diff, ...) therefore cannot be expressed that way, and are applied one level
lower: the `vim.treesitter.start` wrapper in `init.lua` asks `M.disabled()`
before it starts the highlighter.

The two mechanisms are deliberately kept in sync: `M.disable_langs` is handed
to the tree-sitter plugin options, and `M.disabled()` implements the same
list plus the buffer rules.

## Notes
- `help` is not in the language list because Neovim maps that filetype to
  the `vimdoc` language, and `markdown_inline` is the parser that is
  injected into markdown.
- `snacks_*` buffers are not tree-sitter highlighted at all - the wrapper in
  `init.lua` turns the *syntax* on for them instead.
