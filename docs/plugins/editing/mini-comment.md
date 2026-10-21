# editing/mini-comment.lua

Source: `lua/plugins/mini-comment.lua`

## Purpose
Line/visual commenting (`gcc`, `gc`) **without tree-sitter**.

## Plugins
- `nvim-mini/mini.comment`
- `JoosepAlviste/nvim-ts-context-commentstring` (disabled)

## Configuration
- `options.custom_commentstring` returns the buffer's `'commentstring'`.
- `nvim-ts-context-commentstring` (the tree-sitter comment string of the
  LazyVim extra `lazyvim.plugins.extras.coding.mini-comment`) is disabled.

## Why no tree-sitter
The LazyVim extra computes the comment string from the tree-sitter node
under the cursor.  Two problems came with that:

- the comment string was only available once a parser was installed *and* the
  buffer had been parsed;
- computing it calls `vim.filetype.get_option(ft, 'commentstring')`, and that
  runs the *ftplugin* of `ft` in a temporary buffer - which fires the
  `FileType` autocmds of that filetype.  A failing `FileType` autocmd
  (see `lua/config/autocmds.lua`) broke the whole comment operation: `gcc`
  silently did nothing, and only for the *first* comment in a buffer,
  because the option is cached afterwards.

The buffer's `'commentstring'` is used instead - that is what mini.comment
falls back to anyway.  `lazy = false` makes sure the mapping is in place
before the first key press (the built-in `gcc` of Neovim 0.12 uses
tree-sitter as well).
