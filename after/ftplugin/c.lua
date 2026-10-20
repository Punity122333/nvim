local INDENT_WIDTH = require("config.indent_width").width

vim.bo.shiftwidth = INDENT_WIDTH
vim.bo.tabstop = INDENT_WIDTH
vim.bo.softtabstop = INDENT_WIDTH
vim.bo.expandtab = true

vim.opt_local.autoindent = true
vim.opt_local.smartindent = false
vim.opt_local.cindent = false

-- Sane C style if cindent is ever re-enabled as fallback.
vim.opt_local.cinoptions = "l1,g0,N-s,E-s"
vim.opt_local.cinkeys = "0{,0},0),0],:,0#,!^F,o,O,e"
vim.opt_local.indentkeys = "0{,0},0),0],:,0#,!^F,o,O,e"

-- Hybrid C indent: treesitter first, cindent fallback when a `{`
-- opener fails to increase indent (e.g. snippet `if {} {` placeholders).
vim.bo.indentexpr = "v:lua.require'config.cpp_indent'.indentexpr()"
