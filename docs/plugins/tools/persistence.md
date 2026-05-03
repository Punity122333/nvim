# tools/persistence.lua

Source: `lua/plugins/tools/persistence.lua`

## Purpose
Session management with auto-restore for non-home directories.

## Plugins
- `folke/persistence.nvim`

## Configuration
- Session dir: `stdpath("state")/sessions`.
- Keymaps: `<leader>qs` load, `<leader>qS` select, `<leader>ql` last, `<leader>qd` stop.
- Auto-restores session on `VimEnter` when launched without args.
