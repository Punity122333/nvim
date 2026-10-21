# tools/molten.lua

Source: `lua/plugins/molten.lua`

## Purpose
Evaluates code blocks inside the buffer with `molten` and shows the output in a
floating window. The mappings are bound to a `<leader>;` group so they stay out
of the way of the normal editing keys.

## Plugins
- `benlubas/molten-nvim` (pinned to `^1.0.0`)

## Configuration
- `lazy = false` - molten is always loaded, the mappings have to be available.
- `build = ":UpdateRemotePlugins"` so the rplugin remote plugins are generated
  on install.
- `init` sets `vim.g.molten_image_provider = "none"` (no inline image rendering
  in the output window) and `vim.g.molten_output_win_max_height = 20` (the
  output window is capped at 20 lines).

## Keymaps
| Lhs          | Mode   | Description                      |
|--------------|--------|----------------------------------|
| `<leader>;mi`| n      | `MoltenInit python3`             |
| `<leader>;me`| n      | `MoltenEvaluateOperator`         |
| `<leader>;me`| v      | `MoltenEvaluateVisual`           |
| `<leader>;rl`| n      | `MoltenEvaluateLine`             |
| `<leader>;rd`| n      | `MoltenDelete`                   |

`<leader>;me` is mapped twice: in normal mode it evaluates the operator under
the cursor, in visual mode it evaluates the selection.

## Why the output window is height-capped
`molten_output_win_max_height` defaults to `999999`, which lets the output
window grow over the whole screen. The explicit value of 20 keeps it a small
overlay so the evaluated code stays visible.
