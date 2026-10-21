# vcs/git-blame.lua

Source: `lua/plugins/git-blame.lua`

## Purpose
Shows the git blame of the current line as virtual text, with a toggle and
helpers to open the commit URL or copy the commit SHA.

## Plugins
- `f-person/git-blame.nvim`

## Configuration
- `event = "VeryLazy"` - the plugin loads on the `VeryLazy` event.
- `init` sets `vim.g.gitblame_highlight_group = "GitBlame"` before the plugin
  loads, so the virtual text already uses the right group.
- `opts.enabled = true`.
- `opts.date_format = "%r"` - relative time ("2 hours ago") instead of an
  absolute date.
- `opts.message_template = " <author> • <date> • <summary>"`.
- `opts.set_extmark_options = { hl_mode = "combine" }` - the blame text is
  drawn on top of the line background instead of painting it with the default
  (Normal) background.
- `opts.highlight_group = "GitBlame"` - keeps using that group even if the
  `init` block is removed.
- The `GitBlame` highlight group is defined explicitly: `fg = "#8087a2"`,
  `bg = "NONE"`, `italic = true`.

## Why the group is defined by hand
The group is created with `bg = "NONE"` so the blame text inherits the line
background. `transparent.nvim` clears the `GitBlame` prefix for the same
reason - see `ui/transparent.md`.

## Keymaps
| Lhs          | Description          |
|--------------|----------------------|
| `<leader>gb` | Toggle git blame    |
| `<leader>gB` | Open commit URL      |
| `<leader>gs` | Copy commit SHA      |

## Commands
- `:GitBlameToggle` - toggle the blame display.
- `:GitBlameOpenCommitURL` - open the commit URL of the current line.
- `:GitBlameCopySHA` - copy the commit SHA of the current line.
