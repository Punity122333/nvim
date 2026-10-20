-- In-editor PDF reader.
--
-- Renders PDF pages with the Kitty graphics protocol (through snacks.nvim)
-- and falls back to a text-only mode built on pdftotext when the terminal
-- cannot do graphics. Requirements, all of which are already installed:
-- kitty (or ghostty), ImageMagick, ghostscript and poppler-utils.
--
-- Commands: :PDFReader setViewMode {standard,dark,text}, :PDFReader setPage N,
-- :PDFReader showToc, :PDFReader addBookmark, :PDFReader showBookmarks
return {
	"r-pletnev/pdfreader.nvim",
	lazy = false,
	dependencies = {
		"folke/snacks.nvim",
		"nvim-telescope/telescope.nvim",
	},
	-- lazy.nvim calls require("pdfreader").setup(opts) for us.
	opts = {
		mode = 0, -- 0 = normal, 1 = dark, 2 = text
		autosave = true,
	},
}
