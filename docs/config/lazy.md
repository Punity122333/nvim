# config/lazy.lua

Source: `lua/config/lazy.lua`

## Purpose
Bootstraps lazy.nvim and declares where the plugin specs come from.

## Plugins
- `folke/lazy.nvim` (bootstrapped by hand, not by `folke/lazy.nvim` itself)

## Configuration
- Clones lazy.nvim into `stdpath("data") .. "/lazy/lazy.nvim"` if it is not
  there yet, and exits with an error message if the clone fails.
- `spec`:
  - `{ "LazyVim/LazyVim", import = "lazyvim.plugins" }` - the LazyVim extras
    are imported as usual.
  - `{ import = "plugins" }` - every file in `lua/plugins/` is a plugin spec.
- `defaults.lazy = true` (all plugins are lazy-loaded), `version = false`
  (the plugin versions are pinned in `lazy-lock.json`, not in the specs).
- `install.colorscheme` installs `tokyonight` and `habamax`.
- `performance.cache` is enabled, `reset_packpath` is on and the bundled
  plugins `gzip`, `tarPlugin`, `tohtml`, `tutor` and `zipPlugin` are removed
  from the runtime path.
- `ui` uses a backdrop of 100 and rounded borders.

## The `NO_LAZY` environment variable
`NO_LAZY=1` switches the whole setup into "everything at once" mode:
`lazy = false` for every plugin, the plugin count is used as the concurrency
limit, and on `LazyVimStarted` *all* plugins are loaded explicitly. This is
the mode used to measure the startup time with every plugin loaded.

## Notes
- `checker.notify = false`: the update checker does not pop up a window, it
  only sets the `lazy` notification.
- The bootstrap clone is done with `--filter=blob:none --branch=stable`, so
  the repository stays small.
