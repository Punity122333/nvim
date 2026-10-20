local TAB_WIDTH = 4

-- gofmt always indents with tabs and has no flag to change that, so this buffer
-- deliberately keeps 'noexpandtab' instead of following the global 2-space
-- default.
vim.bo.shiftwidth = TAB_WIDTH
vim.bo.tabstop = TAB_WIDTH
vim.bo.softtabstop = 0
vim.bo.expandtab = false