# tools/live-server.lua

Source: `lua/plugins/live-server.lua`

## Purpose
Serves the current project with the `live-server` npm package and reloads the
browser on file changes. It is the quick way to preview static web projects
without leaving Neovim.

## Plugins
- `ngtuonghy/live-server-nvim`

## Configuration
- `cmd = { "LiveServerStart", "LiveServerStop", "LiveServerToggle" }` so the
  commands exist immediately but the plugin body loads only on first use.
- `build = ":LiveServerInstall"`, which npm-installs `live-server` into
  `stdpath("data") .. "/live-server/"`.
- `require("live-server-nvim").setup({})` - no options are overridden, so the
  defaults apply (serve the folder containing `index.html`, or the current
  file with `-f`).

## Why the commands are declared via `cmd`
The plugin defines its user commands at require time. Listing them under `cmd`
makes Neovim know about `:LiveServerStart` / `:LiveServerStop` /
`:LiveServerToggle` right away, while the actual server logic is still
postponed until one of them is used.

## Commands
- `:LiveServerStart [-f]` - start the server (`-f` serves the current file).
- `:LiveServerStop` - stop the running server.
- `:LiveServerToggle` - start or stop, depending on the current state.
- `:LiveServerInstall` - install the `live-server` npm package (also run as
  the plugin `build` step).
