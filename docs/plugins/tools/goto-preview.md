# tools/goto-preview.lua

Source: `lua/plugins/tools/goto-preview.lua`

## Purpose
Opens definition/implementation previews in floating windows.

## Plugins
- `rmagatti/goto-preview`
- `rmagatti/logger.nvim` (dependency)

## Configuration
- Preview window: 120x15 with custom border.
- Keymaps: `gd` (definition), `gpi` (implementation), `gpd` (close).
- Uses Telescope for references and adds `q` to close preview buffer.
