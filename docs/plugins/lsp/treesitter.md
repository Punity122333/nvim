# lsp/treesitter.lua

Source: `lua/plugins/lsp/treesitter.lua`

## Purpose
Treesitter syntax and textobjects configuration with performance guards.

## Plugins
- `nvim-treesitter/nvim-treesitter`
- `nvim-treesitter/nvim-treesitter-textobjects`

## Configuration
- Ensures parsers for C/C++, Lua/Vim, web, and shader languages.
- Disables highlights for diff, large files, and selected filetypes.
- Indent and incremental selection are disabled.
- Prepends local site rtp path for Treesitter runtime.
