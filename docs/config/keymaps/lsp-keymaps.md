# keymaps/lsp_keymaps.lua

Source: `lua/config/keymaps/lsp_keymaps.lua`

## Purpose
The LSP keys that are not owned by a plugin.

## Plugins
- None directly (the action is `vim.lsp.buf.code_action`).

## Configuration
| Mode | Key | Action |
| --- | --- | --- |
| `n` | `<leader>ca` | code action at the cursor |

Everything else (`gd`, `gr`, `gI`, `gy`, `gD`, `gK`, `<c-k>`, `<leader>cr`,
`<leader>cA`, `<leader>co`, `<leader>cc`, `]]`, `[[`, ...) comes from
LazyVim's nvim-lspconfig `config`, which this config deliberately does not
replace (see `docs/plugins/lsp/lsp.md`).

## Notes
- `TSRestart` used to be defined here **and** in `plugin_keymaps.lua`.
  `nvim_create_user_command` does not complain about a duplicate, it just
  replaces the old one, so one of the two definitions was dead all along.
  The command belongs to the tree-sitter plugin and lives in
  `plugin_keymaps.lua` now.
