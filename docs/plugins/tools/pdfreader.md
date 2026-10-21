# tools/pdfreader.lua

Source: `lua/plugins/pdfreader.lua`

## Purpose
Renders PDF files inside Neovim, either as images through the Kitty graphics
protocol or as plain text when the terminal cannot do graphics.

## Plugins
- `r-pletnev/pdfreader.nvim`
- `folke/snacks.nvim` (dependency)
- `nvim-telescope/telescope.nvim` (dependency)

## Configuration
- `lazy = false` - the plugin registers its commands on load, so it is always
  available.
- `opts.mode = 0` - starts in normal (light) view mode.
- `opts.autosave = true` - the current view mode is persisted.
- lazy.nvim calls `require("pdfreader").setup(opts)` automatically.

## Why snacks.image is not used for PDFs
`lua/plugins/snacks.lua` drops the `pdf` format from `snacks.image` on purpose:
pdfreader.nvim owns `.pdf` buffers (paging, text mode, bookmarks, TOC) and
snacks.image would otherwise hijack the same buffer via its own `BufReadCmd`.

## Requirements
kitty (or ghostty), ImageMagick, ghostscript and poppler-utils (`pdftotext`).
Without a graphics-capable terminal the reader falls back to the text-only
mode built on `pdftotext`.

## Commands
- `:PDFReader setViewMode {standard,dark,text}` - switch the view mode.
- `:PDFReader setPage N` - jump to a page.
- `:PDFReader showToc` - show the table of contents.
- `:PDFReader addBookmark` - bookmark the current page.
- `:PDFReader showBookmarks` - list the bookmarks.
