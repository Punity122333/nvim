# tools/shader.lua

Source: `lua/plugins/tools/shader.lua`

## Purpose
Adds shader filetype detection and optional LSP config.

## Plugins
- `nvim-treesitter/nvim-treesitter`
- `neovim/nvim-lspconfig` (optional)

## Configuration
- Adds filetype mappings for GLSL, HLSL, and WGSL extensions.
- Configures `glsl_analyzer` server when `lspconfig` is available.
