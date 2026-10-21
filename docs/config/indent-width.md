# config/indent_width.lua

Source: `lua/config/indent_width.lua`

## Purpose
The single owner of the indentation width.

## Plugins
- None (core Neovim only).

## Configuration
- `M.width = 2` - one level of indentation is 2 columns.
- `M.column_width = 120` - the maximum line length.
- `M.shiftwidth(buf?)` returns the `'shiftwidth'` of the buffer, or the
  default width when the option is unset or 0.

The width is used by `lua/config/options.lua` (which sets `'shiftwidth'`,
`'tabstop'` and `'softtabstop'`), by `cpp_indent.lua` and by
`react_indent.lua`.

## Notes
- LazyVim loads its own defaults (`shiftwidth=2`, `tabstop=2`) *before*
  `options.lua`, so the values here win.
- The file is deliberately tiny: it is required by several other modules
  (including the ones that are loaded before `options.lua`), so it must not
  depend on anything else.
