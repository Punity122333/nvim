-- General Keymaps
--
-- NOTE: `<leader>rb` (refresh buffer) used to be mapped here *and* in
-- `lua/config/keymaps/plugin_keymaps.lua`, where the other buffer commands
-- live.  A duplicate mapping silently replaces the previous one, so one of
-- the two was always dead; the plugin file keeps it.
vim.keymap.set("v", ">", function()
	local saved = vim.o.lazyredraw
	vim.o.lazyredraw = true
	vim.cmd("normal! >")
	vim.cmd("normal! gv")
	vim.o.lazyredraw = saved
end, { noremap = true, silent = true, desc = "Indent and reselect" })

vim.keymap.set("v", "<", function()
	local saved = vim.o.lazyredraw
	vim.o.lazyredraw = true
	vim.cmd("normal! <")
	vim.cmd("normal! gv")
	vim.o.lazyredraw = saved
end, { noremap = true, silent = true, desc = "Unindent and reselect" })
vim.keymap.set("n", "g]", vim.diagnostic.open_float)
vim.keymap.set("i", "<A-h>", "<Left>", { desc = "Move cursor left", silent = true })
vim.keymap.set("i", "<A-j>", "<Down>", { desc = "Move cursor down", silent = true })
vim.keymap.set("i", "<A-k>", "<Up>", { desc = "Move cursor up", silent = true })
vim.keymap.set("i", "<A-l>", "<Right>", { desc = "Move cursor right", silent = true })

vim.keymap.set({ "n", "v" }, "<leader>y", '"+y')
vim.keymap.set({ "n", "v" }, "<leader>p", '"+p')
vim.keymap.set("t", "<Esc>", function()
	vim.cmd("stopinsert")
end, { noremap = true, silent = true })

vim.keymap.set("n", "<leader>uj", function()
  local img = require("snacks.image")
  local buf = vim.api.nvim_get_current_buf()
  local new_val = not img.config.doc.float

  Snacks.config.image.doc.float = new_val
  img.config.doc.float = new_val

  if new_val then
    vim.b[buf].snacks_image_attached = false
    img.doc._attach(buf)
  else
    img.doc.hover_close()
    pcall(vim.api.nvim_del_augroup_by_name, "snacks.image.doc." .. buf)
  end

  vim.notify("Hover images: " .. (new_val and "ON" or "OFF"))
end, { desc = "Toggle hover image previews" })
