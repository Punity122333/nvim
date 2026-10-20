local INDENT_WIDTH = require("config.indent_width").width

vim.bo.commentstring = "// %s"
vim.bo.shiftwidth = INDENT_WIDTH
vim.bo.tabstop = INDENT_WIDTH
vim.bo.softtabstop = INDENT_WIDTH
vim.bo.expandtab = true
