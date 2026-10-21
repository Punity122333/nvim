# lsp/treesitter.lua

Source: `lua/plugins/treesitter.lua`

## Purpose
Treesitter syntax and textobjects configuration with performance guards.

## Plugins
- `nvim-treesitter/nvim-treesitter`
- `nvim-treesitter/nvim-treesitter-textobjects`

## Configuration
- Written against the current `nvim-treesitter` (`main` branch) API:
  `ensure_installed`, `highlight.disable` (a *list of languages*),
  `indent.enable` and `folds.enable`.
- The options are merged into LazyVim's own tree-sitter options
  (`opts = function(_, opts)`), so LazyVim's defaults and the ones the
  enabled extras add are kept.  `ensure_installed` ends up with 63
  parsers: LazyVim's list, the extras' lists, plus `css`, `glsl`, `hlsl`
  and `wgsl`.
- `install_dir` is set to `stdpath("data")/site`, which is where the
  parsers are installed.  nvim-treesitter puts that directory on the
  runtimepath itself, so no manual `rtp` juggling is needed.
- The spec deliberately has **no** `config` function: a user `config`
  replaces LazyVim's, and LazyVim's is what installs the missing parsers
  and starts the highlighter.

## Disabled highlighting
The rules live in `lua/config/treesitter.lua` and are applied in two
places:
- `highlight.disable` (languages): `diff`, `gitcommit`, `markdown`,
  `markdown_inline`, `vimdoc` (which is what the `help` filetype maps to).
  The `latex` entry that the `tex` extra brings is kept.
- `M.disabled(buf)`, consulted by the `vim.treesitter.start` wrapper in
  `init.lua`, for the rules that are not per-language: diff windows, C/C++
  files with more than 1000 lines and files bigger than 100 kB.
