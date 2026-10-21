# config/numbers.lua

Source: `lua/config/numbers.lua`

## Purpose
The single owner of the line-number options.

## Plugins
- None (core Neovim only).

## Configuration
- `M.sync()` copies the **global** `'number'` and `'relativenumber'` values
  into the current window.
- `M.toggle()` flips the global `'relativenumber'` and applies it to every
  window. It returns the new value.

The toggle is bound to `<leader>uN` (see `keymaps/plugin-keymaps.md`).

## Why the global value is the one that is toggled
`'number'` and `'relativenumber'` are global-local options. `init_sc` (see
`options.md`) hides them in the special buffers (dap, avante, the snacks
pickers, ...), which means it also has to set them *explicitly* in the
normal buffers - and that is exactly where a plain
`vim.wo.relativenumber = x` toggle gets lost: the toggle sets the value of
the current window, and the next `BufEnter` overwrites it again.

So the global value is the one that is toggled, and `sync()` copies it into
the windows. The global value is read with `scope = "global"` on purpose:
`vim.opt.<name>:get()` returns the *effective* (local) value, which is
exactly the thing that is being overwritten here.
