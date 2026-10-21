# after/ftplugin.md

Source: `after/ftplugin/*.lua`

## Purpose
Buffer-local options that are only valid for one filetype. They are sourced when the
filetype is set, after the plugins have configured themselves, so they win over the
global options in `lua/config/options.lua`.

There is no other `ftplugin/` in this config - these ten files are the only filetype
specific setup.

## Files
- `c.lua` - C indentation: global indent width, `autoindent` on, `cindent` off, hybrid
  tree-sitter/`cindent` `indentexpr`.
- `cpp.lua` - same as `c.lua` for C++.
- `h.lua` - same hybrid indent setup for C headers.
- `hpp.lua` - same hybrid indent setup for C++ headers.
- `go.lua` - 4-column indent with hard tabs, matching `gofmt`.
- `python.lua` - 4-column indent with soft tabs, matching `ruff format` (Black).
- `glsl.lua` - GLSL: `// %s` comment string, global indent width, `syntax=glsl`.
- `hlsl.lua` - HLSL: `// %s` comment string, global indent width, `syntax=hlsl`.
- `wgsl.lua` - WGSL: `// %s` comment string, global indent width.
- `tex.lua` - LaTeX: VimTeX indent expression, `<leader>cl` re-indent and `<C-=>`
  delimiter completion.

## Configuration
- The indent width comes from `require("config.indent_width").width` (2) unless the
  formatter of that language hard-codes it (`go.lua` and `python.lua` use 4).
- `expandtab` is on everywhere; `go.lua` is the exception because `gofmt` always
  indents with tabs and has no option to change that.
- `smartindent` and `cindent` are off in the C-family files; `cinoptions`, `cinkeys` and
  `indentkeys` are still set as the fallback style
  (`l1,g0,N-s,E-s` / `0{,0},0),0],:,0#,!^F,o,O,e`).
- The C-family files use `indentexpr = v:lua.require'config.cpp_indent'.indentexpr()`:
  tree-sitter first, `cindent` as fallback when a `{` opener fails to increase the
  indent (snippet placeholders such as `if {} {`).
- `tex.lua` disables `autoindent`/`smartindent` and delegates to
  `vimtex#indent#do(v:lnum)`; the keymaps are buffer-local.
