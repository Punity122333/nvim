# config/

## Purpose
The core of the configuration: everything that is *not* a plugin spec.

`lua/config/` holds the files that are loaded directly by `init.lua` (or that
other config files require). They own the options, the keymaps, the autocmds,
the palette and the indentation rules - the parts of the setup that have to
be consistent across all plugins.

## Contents
- `lazy.md` - lazy.nvim bootstrap and the plugin spec layout
- `options.md` - global options, the status column and the sign column
- `autocmds.md` - the autocmds of the configuration
- `highlights.md` - the palette and every custom highlight group
- `treesitter.md` - the rules that decide where the highlighter is not started
- `numbers.md` - the owner of the line-number options
- `keymaps.md` - the keymaps that are not owned by a plugin
- `indent-width.md` - the indentation width (one level = N columns)
- `indent-predicates.md` - the extra tree-sitter query predicate
- `clauseclose.md` - auto-closing of blocks on `<CR>`
- `cpp-indent.md` - the C/C++ `indentexpr`
- `react-indent.md` - the JSX/TSX `indentexpr`

## Rules of this folder
- **One owner per concern.** A colour is defined in `highlights.lua` and
  nowhere else, a line-number option in `numbers.lua`, an indentation width
  in `indent-width.lua`. The other files *read* them.
- **No plugin logic.** If a setting only makes sense for one plugin, it
  belongs in that plugin's file in `lua/plugins/`.
- **Comments explain the "why".** A lot of the code in here is a workaround
  for a bug in a plugin or in Neovim; those comments are the most valuable
  part of the file and are carried over into the docs.
