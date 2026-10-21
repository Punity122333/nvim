# misc/which-key.lua

Source: `lua/plugins/which-key.lua`

## Purpose
Provides keymap discovery with a minimal delay configuration.

## Plugins
- `folke/which-key.nvim`

## Configuration
- `lazy = false` with delay set to 300ms.
- `spec` adds the `<leader>gh` group.
- The trigger mappings are re-created **without `nowait`**.

## Why the triggers are patched
which-key registers a trigger mapping for every prefix it knows (`g`,
`<leader>`, ...).  Those triggers are created with `nowait = true`, so the
prefix key is swallowed *immediately* - Neovim does not even look whether a
longer mapping matches.  The rest of the sequence is then a race between
which-key's 50ms poll and Neovim's own input handling:

- a fast `gcc` was sometimes eaten by the popup, and the leftover keys did
  something else entirely (`cc` changed the line);
- the comment mappings (`gc`, `gcc` of mini.comment) were unreliable.

Without `nowait`, Neovim waits for `'timeoutlen'` first: a longer mapping
(`gcc`) wins, and the popup still shows up when the prefix is used on its
own - which is what the popup is for.

`'ttimeoutlen'` matters for the same reason (it is the timeout of the
ambiguous `gc` / `gcc` pair); it is 300ms, see `lua/config/options.lua`.
