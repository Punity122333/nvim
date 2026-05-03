# tools/autosave.lua

Source: `lua/plugins/tools/autosave.lua`

## Purpose
Automatically saves files on specific events with safety checks.

## Plugins
- `okuuva/auto-save.nvim`

## Configuration
- Triggers on `InsertLeave` and `BufReadPre`.
- Immediate save on `BufLeave` and `FocusLost`.
- Debounce delay set to 20000ms.
- Skips insert/visual/cmdline modes and active snippet sessions.
- Excludes filetypes: `gitcommit`, `gitrebase`, `hgcommit`, `oil`.
- `noautocmd = true`, `write_all_buffers = false`.
