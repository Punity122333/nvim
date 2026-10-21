# init.lua

Source: `init.lua`

## Purpose
The entry point of the configuration: the environment, the theme and the
global commands.

## Plugins
- None directly. The file boots lazy.nvim (`config/lazy.lua`), loads the
  palette (`config/highlights.lua`) and the tree-sitter query predicate
  (`config/indent_predicates.lua`).

## Configuration
### The environment
- `vim.g.python3_host_prog` points at the virtualenv of molten
  (`~/.local/share/molten/venv/bin/python`).
- `vim.loader` is enabled (the Lua module cache).
- `$PATH` is extended with `~/.npm-global/bin`, `~/.local/bin`,
  `~/.local/share/nvim/mason/bin`, `~/.ghcup/bin` and `~/.cabal/bin`. The
  last two are needed by mason to install the Haskell language server and
  the debug adapter.
- `package.path` / `package.cpath` are extended with the LuaRocks directory
  (`~/.luarocks`).
- `RUST_SRC_PATH` is set to a local copy of the Rust standard library
  sources when the system-wide ones are *not* installed. rust-analyzer needs
  the *sources* to resolve `std` items; without them it does not even know
  about `println!`, `String` or `Vec` and only completes the primitive
  types.
- On Wayland the clipboard is `wl-copy` / `wl-paste` (with caching).
- `vim.g.copilot_debug = 1`.

### The tree-sitter wrapper
`vim.treesitter.start` is wrapped: the `snacks_*` buffers get the *syntax*
highlighting instead, and everything else is checked against
`config.treesitter.disabled()` before the highlighter is started.

### Commands
| Command | Action |
| --- | --- |
| `hi` (mapping) | `:Inspect<CR>` - inspect the word under the cursor |
| `RefreshAll` | `bufdo edit!` - reload every buffer from disk |
| `Format` | format the buffer (async, with the LSP as a fallback); with a range it formats only that range |

### The theme
`apply_theme()` re-tints the whole UI after the colorscheme was loaded (and
after every colorscheme change):

- every highlight group that has a background is re-tinted with the primary
  background, unless it is *protected* (`PROTECTED_PATTERNS`: the border,
  prompt, visual, search, menu, completion, float, message, diagnostic,
  status line, snippet, lualine, noice, Avante, DAP, git sign groups, ...),
- the selection groups (the snacks picker, telescope, `CursorLine`) get the
  selection colour instead,
- the `@markup`, `@markdown`, `@conceal` and `@spell` groups get a `NONE`
  background,
- the cursor groups are set to the palette colours,
- the diagnostic underlines are forced on, `DiagnosticUnnecessary` is
  dimmed and struck through,
- the LSP reference groups are re-tinted.

The function is registered on `ColorScheme` and `VimEnter` in the
`ThemeGodMode` augroup and is also called once at startup.

## Notes
- The palette itself lives in `lua/config/highlights.lua`, so that every
  colour is defined exactly once.
- The cursor is drawn by the *terminal* (kitty): Neovim only sends the
  colour (OSC 12) and kitty paints the block itself. The cursor groups are
  therefore set **without** `bold` - kitty caches the cell under the cursor
  and restores that copy when the cursor leaves, and with the bold attribute
  the restored cell was bold, which showed up as a ghost of the old cursor
  position.
- `'formatoptions'` drops the `o` and `r` flags, `'paste'` is off,
  `'autoindent'` is on, `'smartindent'` and `'cindent'` are off.
- The `regex` extension is mapped to the `regex` filetype.
- render-markdown is disabled in `lua/plugins/render-markdown.lua`, so the
  `rm.attach` patch that used to live here was removed together with the
  `require` that poked lazy.nvim's module loader on every startup.
- There used to be a `vim.notify` override here that swallowed every message
  containing the word "Avante". It was broken twice over: it captured
  `vim.notify` *before* snacks/noice had replaced it (so the queue of pending
  notifications was never drained and eventually overflowed), and noice
  replaced the override again, so it never silenced anything. Avante's
  errors and warnings are worth seeing, so nothing is filtered any more.
