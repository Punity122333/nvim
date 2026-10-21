# config/keymaps.md

Source: `lua/config/keymaps.lua`

## Purpose
The keymaps that are not owned by a plugin, plus the scroll behaviour.

## Plugins
- `folke/snacks.nvim` (the terminal used by `<leader>cx`).
- `greggorios/snip.nvim` (the `<C-Tab>` snippet jump).

## Configuration
### The keymap files
The file only pulls in the four keymap modules and then defines what is
left:

- `keymaps/general-keymaps.md` - editing and clipboard keys
- `keymaps/lsp-keymaps.md` - the LSP keys
- `keymaps/movement-keymaps.md` - movement and the outline
- `keymaps/plugin-keymaps.md` - the keys of the plugins (terminal, lazygit,
  DAP, telescope, snipe, flash, ...)

### Save and quit
`WQ`, `Wq`, `WQA` and `Wqa` save every buffer, disable the auto-save, save
the session (persistence) and then quit. The `wq`/`wqa` commands are
abbreviated to them on the command line.

### Scrolling
The mouse wheel scrolls **three lines** vertically and **six columns**
horizontally per notch, and it never scrolls past the `'scrolloff'` margin:
the cursor is moved back into the visible area instead of the screen being
scrolled away from it.

- The scroll is *queued* and applied in one `vim.schedule`d call, so a fast
  wheel does not repaint the screen for every notch.
- `'eventignore'` is set to `all` while the view is restored, so the
  scrolling does not trigger the autocmds of the other plugins.
- In insert mode the scroll is applied immediately (no queue), because the
  queued version would lag behind the text.
- A click (`<LeftMouse>`) within **120ms** of a scroll is swallowed, so that
  a scroll gesture does not leave the cursor behind.

### Other keys
- `H` / `L` are the screen edges (top / bottom).
- `g\` and `g/` insert blank line(s) below the cursor (`g/` also jumps to
  the last one).
- `]o` / `[o` jump to the next / previous `TODO`, `FIXME` or `HACK`
  comment. The search stops at comments, so it does not jump into a comment
  block.
- `<leader>cx` compiles **and runs** the current C++ file
  (`g++ -O3 -std=c++20 -Wall`) in a snacks terminal on the right, with the
  `cwd` set to the directory of the file so that the relative path stays
  valid.

## Why `H`/`L` are the screen edges
Three different plugins wanted them:
- LazyVim's bufferline maps `<S-h>`/`<S-l>` to prev/next buffer - that is
  the *same* key sequence as `H`/`L`, so the two silently fought over one
  key.
- `lua/plugins/multi.lua` mapped `H`/`L` to prev/next multicursor.
- this file maps them to the screen edges.

The bufferline mappings are removed explicitly so that `:map` does not show
two different actions for one key, and the multicursor actions moved to
`\h`/`\l`.

## Why `<leader>cx` and not `<leader>cr`
`<leader>cr` is LazyVim's *LSP rename*. The two mappings silently fought
over the key and the rename was unreachable, so "compile & run" moved to
`<leader>cx` and both work now.

## Notes
- `vim.keymap.del` throws when the mapping does not exist, hence the `pcall`
  around the bufferline mappings.
- The telescope emoji extension is **not** loaded here any more: it raised
  "extension doesn't exist" in every non-markdown buffer, and the error
  aborted the rest of the file, so every mapping below it was silently
  dropped. The extension and the `<leader>se` mapping belong to
  `lua/plugins/emoji.lua`.
