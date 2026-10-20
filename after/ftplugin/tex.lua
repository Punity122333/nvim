local INDENT_WIDTH = require("config.indent_width").width

vim.opt_local.smartindent = false
vim.opt_local.autoindent  = false

vim.opt_local.indentexpr  = "vimtex#indent#do(v:lnum)"

vim.opt_local.shiftwidth  = INDENT_WIDTH
vim.opt_local.tabstop     = INDENT_WIDTH
vim.opt_local.softtabstop = INDENT_WIDTH
vim.opt_local.expandtab   = true

vim.keymap.set("n", "<leader>cl", "gg=G<C-o>", { buffer = true, desc = "Fix LaTeX Indent" })

vim.keymap.set("i", "<C-=>", "<plug>(vimtex-delim-close)",
    { buffer = true, silent = true, desc = "VimTeX: Close delimiter/env" })
