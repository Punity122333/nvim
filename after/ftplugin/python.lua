local INDENT_WIDTH = 4

-- ruff format is Black-compatible: its indent width is fixed at 4 and exposes
-- no option to change it, so the buffer has to agree with the formatter rather
-- than the global 2-space default.
vim.bo.shiftwidth = INDENT_WIDTH
vim.bo.tabstop = INDENT_WIDTH
vim.bo.softtabstop = INDENT_WIDTH
vim.bo.expandtab = true