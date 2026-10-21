# after/

## Purpose
`after/` is the part of a Neovim configuration that is loaded *last*. `after/ftplugin/`
is sourced when a filetype is entered, and `after/queries/` is found at the end of the
runtime path, so its tree-sitter queries are read after the ones shipped by the plugins
and win wherever they capture a node.

This config uses it for two things: buffer-local options that are only valid for one
filetype (indentation width, comment string, filetype keymaps) and tree-sitter query
overrides (coloured brackets, template-literal injections).

There is no other `ftplugin/` in this config, and `after/queries/` holds nothing but the
overrides described in `queries.md`.

## Contents
- `ftplugin.md` - buffer-local options for ten filetypes: C/C++ and their headers, Go,
  Python, GLSL/HLSL/WGSL and LaTeX.
- `queries.md` - tree-sitter highlight overrides for 230 languages plus the JS/JSX/TSX/
  TypeScript template-literal injections.
