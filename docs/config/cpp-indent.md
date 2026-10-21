# config/cpp_indent.lua

Source: `lua/config/cpp_indent.lua`

## Purpose
The `indentexpr` of the C/C++ buffers: a hybrid of tree-sitter and `cindent`.

## Plugins
- `nvim-treesitter/nvim-treesitter` (the tree-sitter indent).
- LazyVim's tree-sitter extra (the fallback).

## Configuration
`M.indentexpr()` is installed as the `'indentexpr'` of the `c`, `cpp`, `h`
and `hpp` buffers (see `docs/config/autocmds.md`).

1. The tree-sitter indent is computed first
   (`LazyVim.treesitter.indentexpr()`, falling back to
   `nvim-treesitter.indentexpr()`).
2. If tree-sitter bailed out (no parser, no query or an error), the pure
   `cindent()` result is used. `vim.fn.cindent()` computes independently of
   the `'cindent'` option, so it works even though `'cindent'` is off.
3. If tree-sitter returned a value that is *not* greater than the indent of
   the previous line and that line ends with `{`, `cindent()` is used as well
   (and, if that fails too, `previous indent + shiftwidth`).
4. Otherwise the tree-sitter value is returned.

## The block-opener guard
A line that ends with `{` must increase the indent. Snippet placeholders
(e.g. `if {} {`) can parse oddly and make tree-sitter return a value at or
below the parent indent (parent 8 -> 6), which produces a broken
indentation. The guard catches exactly that case.

## Notes
- `'cindent'` and `'smartindent'` are off for these buffers, `'autoindent'`
  is on (see `docs/config/autocmds.md`).
- The `indentexpr` is only set when it is still empty, because LazyVim's
  `set_default` only sets *unset* options.
- The indentation width comes from `lua/config/indent_width.lua`.
