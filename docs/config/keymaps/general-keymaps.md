# keymaps/general_keymaps.lua

Source: `lua/config/keymaps/general_keymaps.lua`

## Purpose
The editing and clipboard keys that are not owned by a plugin.

## Plugins
- `folke/snacks.nvim` (the image hover).

## Configuration
### Keys
| Mode | Key | Action |
| --- | --- | --- |
| `v` | `>` | indent and reselect |
| `v` | `<` | unindent and reselect |
| `n` | `g]` | open the diagnostics float |
| `i` | `<A-h>` `<A-j>` `<A-k>` `<A-l>` | move the cursor left / down / up / right |
| `n`, `v` | `<leader>y` | yank to the system clipboard (`"+`) |
| `n`, `v` | `<leader>p` | paste from the system clipboard (`"+`) |
| `t` | `<Esc>` | stop the insert mode in the terminal |
| `n` | `<leader>uj` | toggle the image hover preview |

### Details
- `>` / `<` in visual mode set `'lazyredraw'` while they run and restore the
  selection with `gv`, so the screen is not repainted in between.
- `<A-h>` and friends in insert mode are the *cursor* movement, not the
  window movement (that is `smart-splits`, see
  `lua/plugins/smart-splits.lua`).

## Notes
- `<leader>rb` (refresh buffer) used to be mapped here **and** in
  `plugin_keymaps.lua`, where the other buffer commands live. A duplicate
  mapping silently replaces the previous one, so one of the two was always
  dead; the plugin file keeps it.
- The image hover is toggled by flipping `Snacks.config.image.doc.float`,
  re-attaching (or closing) the document and removing the per-buffer
  augroup, so the state stays consistent.
