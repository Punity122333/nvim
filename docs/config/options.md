# config/options.lua

Source: `lua/config/options.lua`

## Purpose
Owns the global options of the editor and the status column.

## Plugins
- None (core Neovim only).

## Configuration
### General options
- `'timeoutlen'` and `'ttimeoutlen'` are both **300ms**.
- `'updatetime'` is 400ms.
- `'expandtab'` is on, `'shiftwidth'`, `'tabstop'` and `'softtabstop'` are
  all the indentation width (see `indent-width.md`).
- `'wrap'` is off, `'scrolloff'`/`'sidescrolloff'` are 8.
- `'foldenable'` is on, `'signcolumn'` is `no` (the status column replaces
  it), `'list'` is off, `'spell'` is off, `'hlsearch'` is off.
- `'conceallevel'` is 3, `'concealcursor'` is **empty** (never conceal the
  cursor).
- `'winborder'` is `rounded`, `'ttyfast'` is on, `'swapfile'` is off.
- `'shortmess'` gets an `S` (no intro screen).
- `vim.ui.open` opens files with `xdg-open`.
- `vim.g.loaded_matchit`, `loaded_netrwPlugin` and `loaded_matchparen` are
  set to disable the built-in completion / match-paren.
- `vim.g.vimtex_syntax_conceal` disables every kind of VimTeX concealment.

### Highlights
The `ColorScheme`/`VimEnter` autocmd sets the background of the float and
status groups to `none` and gives the signature help window its own dark
background (`#15151c`) with a `#232330` border.

### The status column
Two implementations are provided, both as global functions that Neovim calls
for every rendered line:

- `StatusColumn()` - the *full* column: DAP breakpoints, the diagnostic
  sign, the marks, the line number and the gitsigns column.
- `StatusColumnSimple()` - signs and line number only.

`<leader>Us` switches between the two (for every window at once).

The simple variant caches its data, because it is evaluated for every
rendered line and an extmark query per line is not free:

- the list of namespaces is cached and invalidated when a plugin is loaded
  (`User LazyLoad`),
- the namespaces that actually have marks in a buffer are refreshed at most
  every 500ms,
- the signs themselves are indexed by line and refreshed at most every 100ms.

Buffers that must not show a status column (trees, pickers, terminals, DAP
windows, Avante, ...) are listed in `SC_EXCLUDE`; the numbers are hidden in
them as well. The `BufEnter`/`FileType` autocmd (`init_sc`) applies this per
buffer.

## Why the caches
Without them a redraw of a screen full of lines costs hundreds of
`nvim_buf_get_extmarks` calls. A redraw that takes longer than the terminal
expects means that the terminal keeps showing the *old* screen while the
cursor has already moved - that is the "lagging cursor" (and the ghost of the
old cursor position) that the config tries to avoid everywhere.

## Notes
- The signature help floats get `winhighlight` set to a dedicated background
  so that they do not inherit the (transparent) editor background.
- `vim.g.lazygit_config = false` keeps lazygit from reading the Neovim
  config.
- When `KITTY_SCROLLBACK_NVIM=true` (the kitty scrollback plugin), matchit
  and netrw are disabled as well.
