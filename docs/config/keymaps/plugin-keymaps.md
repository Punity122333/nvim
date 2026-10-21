# keymaps/plugin_keymaps.lua

Source: `lua/config/keymaps/plugin_keymaps.lua`

## Purpose
The keys of the plugins that do not register their own.

## Plugins
- `folke/snacks.nvim` (terminal, picker, explorer)
- `akinsho/toggleterm.nvim` (lazygit)
- `LSP-Saga/LSP-Saga.nvim`
- `ray-project/snip.nvim` (search, navigation, ripgrep)
- `charliermarsh/flash.nvim`
- `mattn/vim-treesitter` (via `various-textobjs`)
- `yetone/avante.nvim`
- `mfussenegger/nvim-dap`
- `mfussenegger/nvim-dap`
- `lalitmee/browse.nvim` (the `Browse*` commands)
- `folke/grug-far.nvim`

## Configuration
### Terminal and lazygit
| Key | Action |
| --- | --- |
| `<leader>tt` | toggle a float terminal |
| `<leader>t<Up>` / `<leader>t<Down>` | horizontal terminal |
| `<leader>t<Left>` / `<leader>t<Right>` | vertical terminal |
| `<leader>\\` / `<leader>gg` | toggle lazygit |
| `<leader>fv` / `<C-/>` | snacks terminal on the right |
| `<leader>fV` | snacks terminal on the left |
| `<leader>Pv` / `<leader>Ph` | terminal in a vertical / horizontal split |

### Buffers and windows
| Key | Action |
| --- | --- |
| `<leader>br` | delete the current buffer |
| `<leader>bn` / `<leader>bp` | next / previous buffer |
| `<leader>rb` | reload the buffer from disk |
| `<A-S-Up>` / `<A-S-Down>` | resize the window height |
| `<A-S-Left>` / `<A-S-Right>` | resize the window width |

### LSP (LSP-Saga)
`gT` finder, `K` hover doc, `gjd` definition, `gjt` type definition,
`gji` incoming calls, `gjo` outgoing calls, `gjn`/`gjp` next/prev
diagnostic, `gjs` outline, `gjb` symbols in the winbar, `gjl` the
diagnostics of the buffer, `gD` definition, `<leader>lo` outline.

`k` and `j` move by *display line* when no count is given (`gk` / `gj`).

### Search and navigation (snip.nvim)
`<leader>f*` navigates (files, buffers, marks, references, old files,
projects, git files, config files, all buffers, diagnostics of the buffer or
of the workspace), `<leader>s*` searches (autocmds, command history,
commands, help, highlights, icons, jumps, keymaps, location list, man pages,
plugin specs, quickfix, undo history, LSP symbols, pickers, registers,
search history, noice history), `<leader>sg` / `<leader>s.` / `<leader>sb`
ripgrep (root, cwd, buffer), `<leader>sw` / `<leader>sW` grep the word.

### Treesitter and textobjects
| Key | Action |
| --- | --- |
| `S` | flash treesitter jump (global) |
| `<leader>]` | flash treesitter selection (normal, visual, operator) |
| `gkiw` … `gkik` | the various-textobjs subwords, chain members, columns, indentation, the entire buffer, the near line, the URL, the diagnostic and the key |

### Miscellaneous
| Key | Action |
| --- | --- |
| `<leader>md` / `<leader>ml` | delete all marks / the local marks |
| `<leader>fm` | format the file |
| `<leader>mb` | toggle `'list'` |
| `<leader>uN` | toggle the relative line numbers |
| `<leader>uH` | toggle `'list'` |
| `<leader>db` | toggle a DAP breakpoint |
| `<leader>[]` | "LSP panic button": restart every client of the buffer |
| `<leader>fx` | reveal the current file in the snacks explorer |
| `<leader>fD` | search the home directory |
| `<leader>sf` | grug-far on the current file |
| `<i>, <s>` `<C-Tab>` | jump to the next snippet |
| `<i>` `<C-S-k>` | show the Avante suggestion manually |
| `<i>` `<C-f>` | indent the line (`<C-t>`) |
| `o` `f` | `f` stays remapped |

### Commands
`BrowseMain`, `BrowseInput`, `BrowseBookmarks`, `BrowseDevDocs`,
`BrowseDevDocsFT`, `BrowseMDN` (browse.nvim) and `TSRestart`
(tree-sitter).

## Notes
- `<leader>ca` (code action) used to be defined here **and** in
  `lsp_keymaps.lua`. A duplicate mapping does not raise an error, it
  silently replaces the previous one, so one of the two definitions was
  always dead.
- `<C-q>` used to be mapped here **and** in `lua/plugins/case-dial.lua`,
  which owns the plugin and its mappings.
- `vim.keymap.del("n", "hi")` used to live here. It removed the
  `hi` -> `:Inspect<CR>` mapping that `init.lua` sets, so the mapping never
  worked. The mapping is now defined in `init.lua` only.
- The LSP-Saga commands are wrapped in a helper that opens a 1x1 scratch
  window first: the saga commands move the cursor, and without the scratch
  window the cursor jumped to the top of the file.
