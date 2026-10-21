# tools/opencode.lua

Source: `lua/plugins/opencode.lua`

## Purpose
Bridges Neovim into a running `opencode` daemon: ask questions with editor
context, pick one of the built-in prompts, and accept or reject the edits
opencode proposes.

## Plugins
- `nickjvandyke/opencode.nvim`

## Configuration
- `vim.g.opencode_opts = {}` - the plugin merges this with its own defaults.
  No server URL or credential is needed, the plugin discovers the running
  daemon on its own.
- The `snacks.input` / `snacks.picker` integrations are already enabled in
  `lua/plugins/snacks.lua`, so `ask` and `select` get the full picker UI.
- The mappings are declared as `keys` (not inside `config`) so lazy.nvim
  registers them right away and loads the plugin on the first key press.

## Keymaps
| Lhs        | Mode     | Description                |
|------------|----------|----------------------------|
| `<leader>oa` | n, x  | `opencode.ask("@this: ")`  |
| `<leader>os` | n, x  | `opencode.select()`        |
| `<leader>op` | n, x  | `opencode.prompt()`        |

## Why the mappings live under `<leader>`
The plugin's README suggests `<C-a>` / `<C-x>`, but those are already taken by
the `dial` extra (increment / decrement). The mappings were moved under
`<leader>` instead of remapping the dial keys.

## Why the mappings are in `keys` and not in `config`
A plugin spec with only a `config` function is never loaded by lazy.nvim -
nothing would ever trigger the load. Declaring the mappings through `keys`
makes them the lazy-loading trigger.
