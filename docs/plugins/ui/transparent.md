# ui/transparent.lua

Source: `lua/plugins/transparent.lua`

## Purpose
Makes the editor background transparent, so the terminal background shows
through. Can be toggled on and off at runtime.

## Plugins
- `xiyaowong/transparent.nvim`

## Configuration
- `lazy = false` - the plugin has to be loaded to react to the toggle command.
- `setup({ extra_groups = { "GitBlame" } })` - the `GitBlame` highlight group
  is added to the groups that get their background cleared.
- `require("transparent").clear_prefix("GitBlame")` - clears every highlight
  group whose name starts with `GitBlame`.

## Why clear_prefix is called explicitly
`extra_groups` only lists the groups that exist at setup time. `clear_prefix`
registers the prefix, so any `GitBlame*` group that is created later (for
example by `git-blame.nvim`) is cleared as well. See `vcs/git-blame.md`, where
the `GitBlame` group is defined with `bg = "NONE"`.

## Keymaps
| Lhs          | Description               |
|--------------|---------------------------|
| `<leader>ut`| Toggle transparency       |
