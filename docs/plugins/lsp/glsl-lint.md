# lsp/glsl-lint.lua

Source: `lua/plugins/lsp/glsl-lint.lua`

## Purpose
Runs `glslangValidator` via `nvim-lint` for GLSL files.

## Plugins
- `mfussenegger/nvim-lint`

## Configuration
- Defines a `glslangValidator` linter for `glsl`, `vert`, `frag`, `tesc`, `tese`, `geom`, `comp`.
- Parses stderr output into diagnostics with severity mapping.
- Runs lint on write, read, insert leave, and text change events.
