# tools/browse-mdn.lua

Source: `lua/plugins/tools/browse-mdn.lua`

## Purpose
Provides quick web search and DevDocs browsing via Telescope.

## Plugins
- `lalitmee/browse.nvim`
- `nvim-telescope/telescope.nvim` (dependency)

## Configuration
- Keymaps: `<leader>Bw` search, `<leader>Bb` menu, `<leader>Bm` bookmarks, `<leader>Bt` DevDocs.
- Provider set to Google with custom bookmarks and search engines.
- User commands: `BrowseMain`, `BrowseInput`, `BrowseBookmarks`, `BrowseDevDocs`, `BrowseDevDocsFT`, `BrowseMDN`.
