# tools/refactoring.lua

Source: `lua/plugins/tools/refactoring.lua`

## Purpose
Provides common refactors like extract and inline.

## Plugins
- `ThePrimeagen/refactoring.nvim`
- Dependencies: `plenary.nvim`, `nvim-treesitter`, `async.nvim`.

## Configuration
- Prompts for function return/param types in multiple languages.
- Keymaps:
  - `<leader>;e` extract function (visual)
  - `<leader>;f` extract to file (visual)
  - `<leader>;i` inline variable (normal/visual)
  - `<leader>;b` extract block (normal)
  - `<leader>;bf` extract block to file (normal)
