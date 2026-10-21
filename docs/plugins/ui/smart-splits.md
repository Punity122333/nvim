# ui/smart-splits.lua

Source: `lua/plugins/smart-splits.lua`

## Purpose
Direction aware window navigation and resizing: resize with a mental model of
left/right/up/down instead of wider/narrower/taller/shorter, and move the cursor
between splits without the usual `<C-w>` prefix.

## Plugins
- `smart-splits-nvim/smart-splits.nvim` (pinned to `^3.0.0`)
- `smart-splits-nvim/backend-kitty` (dependency, main `smart-splits-backend-kitty`)

## Configuration
- `opts.mux.backend = "smart-splits-backend-kitty"` - the kitty backend makes
  the navigation cross the terminal multiplexer panes as well.
- `opts.mux.warn_if_unusable = false` - no warning when the backend is not
  usable.
- The plugin sets no mappings of its own, so they are all defined here.

## Keymaps
| Lhs                | Description         |
|--------------------|---------------------|
| `<A-h>`            | Resize left         |
| `<A-j>`            | Resize down         |
| `<A-k>`            | Resize up           |
| `<A-l>`            | Resize right        |
| `<C-h>`            | Move cursor left    |
| `<C-j>`            | Move cursor down    |
| `<C-k>`            | Move cursor up      |
| `<C-l>`            | Move cursor right   |
| `<leader><leader>h`| Swap buffer left    |
| `<leader><leader>j`| Swap buffer down    |
| `<leader><leader>k`| Swap buffer up      |
| `<leader><leader>l`| Swap buffer right   |

## Why the kitty backend is added
kitty is the terminal in use, so the kitty backend extends the split navigation
across the multiplexer panes.

It needs `allow_remote_control yes` in `kitty.conf`. Without that setting the
backend is simply not detected - no error, but only the in-editor resizing
works. `warn_if_unusable = false` keeps that silent.
