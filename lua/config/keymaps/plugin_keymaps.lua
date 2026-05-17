local function toggle_lazygit()
	local Terminal = require("toggleterm.terminal").Terminal
	local lazygit = Terminal:new({ cmd = "lazygit", hidden = true, direction = "float" })
	lazygit:toggle()
end
vim.keymap.set("n", "<leader>tt", "<cmd>ToggleTerm direction=float<cr>", { desc = "ToggleTerm Float" })
local opts = { noremap = true, silent = true }
vim.keymap.set("n", "<leader>t<Up>", "<cmd>ToggleTerm direction=horizontal<cr>", opts)
vim.keymap.set("n", "<leader>t<Down>", "<cmd>ToggleTerm direction=horizontal<cr>", opts)
vim.keymap.set("n", "<leader>t<Left>", "<cmd>ToggleTerm direction=vertical<cr>", opts)
vim.keymap.set("n", "<leader>t<Right>", "<cmd>ToggleTerm direction=vertical<cr>", opts)

vim.keymap.set("n", "<leader>\\\\", toggle_lazygit, { desc = "ToggleTerm Lazygit" })
vim.keymap.set("n", "<leader>gg", toggle_lazygit, { desc = "ToggleTerm Lazygit" })

vim.keymap.set("n", "<leader>fv", function()
	Snacks.terminal(nil, { win = { position = "right", width = 0.25 } })
end, { desc = "Terminal Vertical (Right)" })
vim.keymap.set("n", "<C-/>", function()
	Snacks.terminal(nil, { win = { position = "right", width = 0.25 } })
end, { desc = "Terminal Vertical (Right)" })

vim.keymap.set("n", "<leader>fV", function()
	Snacks.terminal(nil, { win = { position = "left", width = 0.25 } })
end, { desc = "Terminal Vertical (Left)" })

vim.keymap.set("n", "<leader>Pv", function()
	vim.cmd("vsplit | term")
	vim.opt_local.number = false
	vim.opt_local.relativenumber = false
end, { desc = "Terminal Vertical Split" })

vim.keymap.set("n", "<leader>Ph", function()
	vim.cmd("split | term")
	vim.opt_local.number = false
	vim.opt_local.relativenumber = false
end, { desc = "Terminal Horizontal Split" })
vim.keymap.set("n", "<leader>br", function()
	Snacks.bufdelete()
end, { desc = "Remove Current Buffer" })
vim.keymap.set("n", "<leader>bn", "<cmd>BufferLineCycleNext<cr>", { desc = "Next Buffer" })
vim.keymap.set("n", "<leader>bp", "<cmd>BufferLineCyclePrev<cr>", { desc = "Previous Buffer" })
vim.keymap.set("n", "<leader>rb", "<cmd>edit!<cr>", { desc = "Refresh Buffer" })


vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "Go to left window" })
vim.keymap.set("n", "<A-S-Up>", "<cmd>resize +2<cr>", { desc = "Increase window height" })
vim.keymap.set("n", "<A-S-Down>", "<cmd>resize -2<cr>", { desc = "Decrease window height" })
vim.keymap.set("n", "<A-S-Left>", "<cmd>vertical resize -2<cr>", { desc = "Decrease window width" })
vim.keymap.set("n", "<A-S-Right>", "<cmd>vertical resize +2<cr>", { desc = "Increase window width" })

vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, { desc = "Code Action" })
vim.keymap.set("n", "<leader>Po", ":silent !zathura <cfile> &<CR>", { desc = "Open PDF in Zathura" })

vim.keymap.set("n", "<leader>uN", function()
	local rn = not vim.wo.relativenumber
	vim.wo.relativenumber = rn
	vim.notify(rn and "Relative numbers" or "Absolute numbers", vim.log.levels.INFO)
end, { desc = "Toggle relative/absolute line numbers" })

vim.api.nvim_create_user_command("TSRestart", function()
	local buf = vim.api.nvim_get_current_buf()
	local lang = vim.treesitter.language.get_lang(vim.bo[buf].filetype)
	if lang then
		vim.treesitter.stop(buf)
		vim.treesitter.start(buf, lang)
		vim.notify("Treesitter restarted for: " .. lang, vim.log.levels.INFO)
	else
		vim.notify("No Treesitter parser for this filetype", vim.log.levels.WARN)
	end
end, { desc = "Restart Treesitter for current buffer" })

local function wrap_saga(cmd)
	return function()
		local bufnr = vim.api.nvim_create_buf(false, true)
		local win = vim.api.nvim_open_win(bufnr, false, {
			relative = "editor",
			width = 1,
			height = 1,
			row = 0,
			col = 0,
			style = "minimal",
		})
		vim.cmd("silent! " .. cmd)
		vim.defer_fn(function()
			if vim.api.nvim_win_is_valid(win) then
				vim.api.nvim_win_close(win, true)
			end
		end, 50)
	end
end

-- Lua (init.lua)
vim.keymap.set("n", "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set("n", "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })
vim.keymap.set("n", "gT", wrap_saga("Lspsaga finder"), { desc = "LSP Finder" })
vim.keymap.set("n", "K", wrap_saga("Lspsaga hover_doc"), { desc = "Hover Docs" })
vim.keymap.set("n", "gjd", wrap_saga("Lspsaga goto_definition"), { desc = "Goto Definition" })
vim.keymap.set("n", "gjt", wrap_saga("Lspsaga peek_type_definition"), { desc = "Peek Type Definition" })
vim.keymap.set("n", "gji", wrap_saga("Lspsaga incoming_calls"), { desc = "Incoming Calls" })
vim.keymap.set("n", "gjo", wrap_saga("Lspsaga outgoing_calls"), { desc = "Outgoing Calls" })
vim.keymap.set("n", "gjn", wrap_saga("Lspsaga diagnostic_jump_next"), { desc = "Next Diagnostic" })
vim.keymap.set("n", "gjp", wrap_saga("Lspsaga diagnostic_jump_prev"), { desc = "Prev Diagnostic" })

vim.keymap.set("n", "<leader>lo", "<cmd>Lspsaga outline<CR>", { desc = "LSP Outline" })
vim.keymap.set("n", "gjs", "<cmd>Lspsaga outline<CR>", { desc = "Toggle Outline" })
vim.keymap.set("n", "gjb", "<cmd>Lspsaga symbols_in_winbar<CR>", { desc = "Winbar Symbols" })
vim.keymap.set("n", "gjl", "<cmd>Lspsaga show_buf_diagnostics<CR>", { desc = "Buffer Diagnostics" })
vim.keymap.set("n", "gD", "<cmd>Lspsaga goto_definition<CR>")

pcall(function()
	require("which-key").add({ { "gj", group = "LSP Navigation" } })
end)

vim.keymap.set("n", "<leader>[]", function()
	local clients = vim.lsp.get_clients({ bufnr = 0 })
	for _, client in ipairs(clients) do
		vim.lsp.stop_client(client.id, true)
	end
	vim.cmd("edit!")
	vim.notify("LSP Clients refreshed for buffer", vim.log.levels.INFO, { title = "LSP Panic" })
end, { desc = "LSP Panic Button (Soft Refresh)" })

local function nav_call(method)
	return function()
		require("snipe.nav")[method]()
	end
end
local function search_call(method)
	return function()
		require("snipe.search")[method]()
	end
end
local function rg_call(method)
	return function()
		require("snipe.rg")[method]()
	end
end

local map = function(keys, func, desc)
	vim.keymap.set("n", keys, func, { desc = desc, silent = true })
end

map("<leader>ff", nav_call("files"), "Files (fd)")
map("<leader>fb", nav_call("buffers"), "Buffers")
map("<leader>f'", nav_call("marks"), "Marks")
map("<leader>fr", nav_call("references"), "LSP References")
map("<leader>fo", nav_call("oldfiles"), "Recent Files")
map("<leader>fp", nav_call("projects"), "Projects")
map("<leader>fg", nav_call("git_files"), "Git files")
map("<leader>fc", nav_call("config_files"), "Config files")
map("<leader>fB", nav_call("all_buffers"), "All buffers")

map("<leader>fd", function()
	require("snipe.nav").diagnostics(false)
end, "Diagnostics (Buffer)")
map("<leader>f;", function()
	require("snipe.nav").diagnostics(true)
end, "Diagnostics (Workspace)")
map("<leader>sd", function()
	require("snipe.nav").diagnostics(false)
end, "Diagnostics (Buffer)")
map("<leader>sD", function()
	require("snipe.nav").diagnostics(true)
end, "Diagnostics (Workspace)")

map("<leader>sa", search_call("autocmds"), "Autocmds")
map("<leader>sc", search_call("cmdhistory"), "Command History")
map("<leader>sC", search_call("commands"), "Commands")
map("<leader>sh", search_call("help"), "Help Pages")
map("<leader>sH", search_call("highlights"), "Highlights")
map("<leader>si", search_call("icons"), "Icons")
map("<leader>sj", search_call("jumps"), "Jumps")
map("<leader>sk", search_call("keymaps"), "Keymaps")
map("<leader>sl", search_call("loclist"), "Location List")
map("<leader>sM", search_call("manpages"), "Man Pages")
map("<leader>sp", search_call("plugins"), "Plugin Spec")
map("<leader>sq", search_call("quickfix"), "Quickfix")
map("<leader>su", search_call("undo"), "Undo History")
map("<leader>sB", search_call("lsp_symbols"), "LSP Symbols")
map("<leader>sP", search_call("pickers"), "Builtin Pickers")
map('<leader>s"', search_call("registers"), "Registers")
map("<leader>s/", search_call("searchhistory"), "Search History")
map("<leader>sn", search_call("noice"), "Noice History")
map("<leader>sg", rg_call("rg"), "Grep (Root)")
map("<leader>s.", rg_call("rg"), "Grep (CWD)")
map("<leader>sb", rg_call("rg_buffer"), "Search Buffer")
map("<leader>fw", rg_call("rg"), "Grep (Fast)")
vim.keymap.set("n", "<leader>/", rg_call("rg"), { desc = "Grep (Root)", remap = true })

map("<leader>sw", function()
	require("snipe.search").grep_word(true)
end, "Grep Word (Root)")
map("<leader>sW", function()
	require("snipe.search").grep_word(false)
end, "Grep Word (CWD)")

vim.keymap.set("n", "<leader>fD", function()
	Snacks.picker.files({
		cwd = vim.fn.expand("~"),
		hidden = true,
		ignored = false,
		title = "Home Search",
		exclude = { "node_modules", ".git", ".cache", "__pycache__", ".venv", "venv", "build", "dist" },
	})
end, { desc = "Search from Home Directory" })

vim.keymap.set("n", "<leader>fx", function()
	Snacks.explorer.reveal()
end, { desc = "Reveal Current File in Explorer" })

vim.keymap.del("n", "<leader>gg")
vim.keymap.set("n", "<leader>gg", toggle_lazygit, { desc = "ToggleTerm Lazygit" })

vim.keymap.set("n", "<leader>sf", function()
	require("grug-far").open({ transient = true, prefills = { paths = vim.fn.expand("%") } })
end, { desc = "Grug Far: Current File" })

vim.keymap.set("n", "<leader>md", "dm<leader>", { desc = "Clear all marks" })
vim.keymap.set("n", "<leader>ml", "dM<leader>", { desc = "Clear local marks" })
vim.keymap.set("n", "<leader>fm", "<cmd>Format<cr>", { desc = "Format file manually" })
vim.keymap.set("n", "<leader>mb", ":set list!<CR>", { noremap = true, silent = true, desc = "Toggle listchars" })
vim.keymap.set("i", "<C-f>", "<C-t>", { desc = "Indent line" })
vim.keymap.set("o", "f", "f", { remap = true })

vim.keymap.set("n", "<leader>uH", function()
	vim.opt.list = not vim.opt.list:get()
	vim.notify(
		vim.opt.list:get() and "Hidden chars enabled" or "Hidden chars disabled",
		vim.log.levels.INFO,
		{ title = "UI Toggle" }
	)
end, { desc = "Toggle List / NoList" })

vim.keymap.set("n", "S", function()
	require("flash").treesitter({
		search = { multi_window = false, wrap = true },
		jump = { pos = "start" },
		action = function(match)
			vim.api.nvim_win_set_cursor(match.win, match.pos)
		end,
		label = { before = true, after = false },
	})
end, { desc = "Global Treesitter Jump" })

vim.keymap.set({ "n", "x", "o" }, "<leader>]", function()
	require("flash").treesitter()
end, { desc = "Flash Treesitter Visual Selection" })

local function map2(mode, lhs, rhs, desc)
	vim.keymap.set(mode, lhs, rhs, { desc = desc, silent = true })
end
local modes = { "n", "o", "x" }

map2(modes, "gkiw", "<cmd>lua require('various-textobjs').subword('inner')<CR>", "Inner Subword")
map2(modes, "gkaw", "<cmd>lua require('various-textobjs').subword('outer')<CR>", "Outer Subword")
map2(modes, "gkim", "<cmd>lua require('various-textobjs').chainMember('inner')<CR>", "Inner Chain Member")
map2(modes, "gkam", "<cmd>lua require('various-textobjs').chainMember('outer')<CR>", "Outer Chain Member")
map2(modes, "gkic", "<cmd>lua require('various-textobjs').column('inner')<CR>", "Inner Column")
map2(modes, "gkac", "<cmd>lua require('various-textobjs').column('outer')<CR>", "Outer Column")
map2(modes, "gkii", "<cmd>lua require('various-textobjs').indentation('inner', 'inner')<CR>", "Inner Indent")
map2(modes, "gkai", "<cmd>lua require('various-textobjs').indentation('outer', 'outer')<CR>", "Outer Indent")
map2(modes, "gkig", "<cmd>lua require('various-textobjs').entireBuffer()<CR>", "Entire Buffer")
map2(modes, "gkin", "<cmd>lua require('various-textobjs').nearLine('inner')<CR>", "Near Line")
map2(modes, "gkiu", "<cmd>lua require('various-textobjs').url()<CR>", "URL")
map2(modes, "gkid", "<cmd>lua require('various-textobjs').diagnostic()<CR>", "Diagnostic")
map2(modes, "gkik", "<cmd>lua require('various-textobjs').key('inner')<CR>", "Key")

pcall(function()
	require("which-key").add({
		{ "gk", group = "various-textobjs" },
		{ "gki", group = "inner" },
		{ "gka", group = "around" },
	})
end)

vim.keymap.set("i", "<C-S-k>", function()
	require("avante.suggestion").show({})
end, { desc = "Manual Avante suggestion" })

vim.keymap.set("n", "<C-q>", function()
	require("case-dial").dial_normal()
end, { desc = "Dial Case" })
vim.keymap.set("v", "<C-q>", function()
	require("case-dial").dial_visual()
end, { desc = "Dial Case" })

vim.keymap.set("n", "<leader>db", function()
	require("dap").toggle_breakpoint()
	vim.cmd("redraw!")
end)

local cmd = vim.api.nvim_create_user_command
local opts2 = {}

cmd("BrowseMain", function()
	require("browse").browse()
end, opts2)
cmd("BrowseInput", function()
	require("browse").input_search()
end, opts2)
cmd("BrowseBookmarks", function()
	require("browse").open_manual_bookmarks()
end, opts2)
cmd("BrowseDevDocs", function()
	require("browse.devdocs").search()
end, opts2)
cmd("BrowseDevDocsFT", function()
	require("browse.devdocs").search_with_filetype()
end, opts2)
cmd("BrowseMDN", function()
	require("browse.mdn").search()
end, opts2)

vim.keymap.del("n", "hi", {})

vim.keymap.set({ "i", "s" }, "<C-Tab>", function()
	if vim.snippet and vim.snippet.active({ direction = 1 }) then
		vim.snippet.jump(1)
		return
	end
end, { silent = true })
