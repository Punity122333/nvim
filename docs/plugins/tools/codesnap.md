# tools/codesnap.lua

Source: `lua/plugins/tools/codesnap.lua`

## Purpose
Creates code snapshots and copies/saves them with custom styling.

## Plugins
- `mistricky/codesnap.nvim`

## Configuration
- Build step: `make build_generator`.
- Visual keymaps:
  - `<leader>cc` copy snap
  - `<leader>cl` save snap
  - `<leader>ca` copy ASCII
  - `<leader>ch` copy highlight (visual/whole buffer)
  - `<leader>cH` save highlight (visual/whole buffer)
- Snapshot theme set to `candy` with custom fonts, watermark, and gradient background.
- Uses a generator module and writes a temp config to `/tmp/codesnap_config.lua`.
- Clipboard integration uses `wl-copy` (Wayland) or `xclip`.
