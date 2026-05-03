# ui/bufferline.lua

Source: `lua/plugins/ui/bufferline.lua`

## Purpose
Tabline buffer UI with custom numbering, styling, and selection emphasis.

## Plugins
- `akinsho/bufferline.nvim`

## Configuration
- Uses `style_preset.default` with LSP diagnostics.
- Custom ordinal labels using a lettermap.
- Offsets for `neo-tree` and `rconsole`; filters out `rconsole` buffers.
- Highlight groups set to a solid Tokyo Night background.
- Emphasizes selected buffer/number/close/pick/duplicate groups in bold.
- Keymaps: `<leader>b[a/s/d/f/g/h/j/k/l/;/' ]` jump to buffers.
