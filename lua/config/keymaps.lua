local COMMAND_SAVE_AND_QUIT = "WQ"
local COMMAND_SAVE_AND_QUIT_ALT1 = "Wq"
local COMMAND_SAVE_AND_QUIT_ALL = "WQA"
local COMMAND_SAVE_AND_QUIT_ALL_ALT1 = "Wqa"
require("config.keymaps.general_keymaps")
require("config.keymaps.lsp_keymaps")
require("config.keymaps.movement_keymaps")
require("config.keymaps.plugin_keymaps")

vim.api.nvim_create_user_command(COMMAND_SAVE_AND_QUIT, function()
	vim.cmd("silent! wall")
	vim.defer_fn(function()
		local ok_autosave, autosave = pcall(require, "auto-save")
		if ok_autosave and autosave then
			vim.g.auto_save_abort = true
		end
		local ok_persist, persistence = pcall(require, "persistence")
		if ok_persist and persistence then
			persistence.save()
		end
		vim.defer_fn(function()
			vim.cmd("qall!")
		end, 100)
	end, 150)
end, { desc = "Save all and quit cleanly" })

vim.api.nvim_create_user_command(COMMAND_SAVE_AND_QUIT_ALT1, function()
	vim.cmd(COMMAND_SAVE_AND_QUIT)
end, { desc = "Save all and quit cleanly", force = true })

vim.api.nvim_create_user_command(COMMAND_SAVE_AND_QUIT_ALL, function()
	vim.cmd(COMMAND_SAVE_AND_QUIT)
end, { desc = "Save all and quit cleanly" })

vim.api.nvim_create_user_command(COMMAND_SAVE_AND_QUIT_ALL_ALT1, function()
	vim.cmd(COMMAND_SAVE_AND_QUIT)
end, { desc = "Save all and quit cleanly" })

vim.cmd([[
  cnoreabbrev <expr> wq getcmdtype() == ":" && getcmdline() == "wq" ? "WQ" : "wq"
  cnoreabbrev <expr> Wq getcmdtype() == ":" && getcmdline() == "Wq" ? "WQ" : "Wq"
  cnoreabbrev <expr> wqa getcmdtype() == ":" && getcmdline() == "wqa" ? "WQA" : "wqa"
  cnoreabbrev <expr> Wqa getcmdtype() == ":" && getcmdline() == "Wqa" ? "WQA" : "Wqa"
]])

-- NOTE: the telescope emoji extension used to be loaded here. Because
-- `allaman/emoji.nvim` was only loaded for markdown/text buffers,
-- `telescope.load_extension("emoji")` raised "extension doesn't exist"
-- in every other buffer -- and since it was not wrapped in pcall, the
-- error aborted the rest of this file, so every mapping below it was
-- silently dropped. The extension and the `<leader>se` mapping are now
-- owned by `lua/plugins/emoji.lua` (which loads eagerly).

local _scroll_ts = 0
local _move_ts = 0
local SCROLL_DEBOUNCE_MS = 120
local _sv = { noremap = true, silent = true }
local _uv = vim.uv or vim.loop
local _pending_v = 0
local _pending_h = 0
local _flush_sched = false

local function apply_scroll(dv, dh)
	local view = vim.fn.winsaveview()

	if dv ~= 0 then
		view.topline = math.max(1, view.topline - dv)

		local winheight = vim.fn.winheight(0)
		local so = vim.o.scrolloff
		local top_limit = view.topline + so
		local bot_limit = view.topline + winheight - 1 - so

		if top_limit > bot_limit then
			view.lnum = view.topline + math.floor(winheight / 2)
		else
			view.lnum = math.max(top_limit, math.min(bot_limit, view.lnum))
		end
	end

	if dh ~= 0 then
		view.leftcol = math.max(0, view.leftcol + dh)
	end

	local ei = vim.o.eventignore
	vim.o.eventignore = "all"
	vim.fn.winrestview(view)
	vim.o.eventignore = ei
end

local function flush_scroll()
	_flush_sched = false
	local dv, dh = _pending_v, _pending_h
	_pending_v, _pending_h = 0, 0
	if dv == 0 and dh == 0 then
		return
	end
	apply_scroll(dv, dh)
end

local function queue_scroll(dv, dh)
	_scroll_ts = _uv.now()
	_pending_v = _pending_v + dv
	_pending_h = _pending_h + dh
	if not _flush_sched then
		_flush_sched = true
		vim.schedule(flush_scroll)
	end
end

for _, dir in ipairs({ "Up", "Down" }) do
	local dv = dir == "Up" and 3 or -3
	local fn = function()
		queue_scroll(dv, 0)
	end
	local i_fn = function()
		_scroll_ts = _uv.now()
		apply_scroll(dv, 0)
	end
	for _, mult in ipairs({ "", "2-", "3-", "4-" }) do
		local lhs = "<" .. mult .. "ScrollWheel" .. dir .. ">"
		vim.keymap.set({ "n", "v" }, lhs, fn, _sv)
		vim.keymap.set("i", lhs, i_fn, _sv)
	end
end

for _, dir in ipairs({ "Left", "Right" }) do
	local dh = dir == "Right" and 6 or -6
	local fn = function()
		queue_scroll(0, dh)
	end
	local i_fn = function()
		_scroll_ts = _uv.now()
		apply_scroll(0, dh)
	end
	for _, mult in ipairs({ "", "2-", "3-", "4-" }) do
		local lhs = "<" .. mult .. "ScrollWheel" .. dir .. ">"
		vim.keymap.set({ "n", "v" }, lhs, fn, _sv)
		vim.keymap.set("i", lhs, i_fn, _sv)
	end
end

local _lm_raw = vim.api.nvim_replace_termcodes("<LeftMouse>", true, false, true)
vim.keymap.set({ "n", "v" }, "<LeftMouse>", function()
	if _uv.now() - _scroll_ts < SCROLL_DEBOUNCE_MS then
		return
	end
	vim.api.nvim_feedkeys(_lm_raw, "n", false)
end, _sv)

vim.api.nvim_create_autocmd({ "WinEnter", "BufEnter", "FocusGained" }, {
	callback = function()
		_scroll_ts = _uv.now()
	end,
})

-- `H`/`L` are the screen edges and belong to *this* file.
--
-- Three different plugins wanted them:
--   * LazyVim's bufferline maps `<S-h>`/`<S-l>` to prev/next buffer.  That
--     is the *same* key sequence as `H`/`L`, so the two silently fought
--     over one key.
--   * `lua/plugins/multi.lua` mapped `H`/`L` to prev/next multicursor.
--   * this file maps them to the screen edges.
-- The bufferline mappings are removed explicitly (below) so that `:map`
-- does not show two different actions for one key, and the multicursor
-- actions moved to `\h`/`\l` (see `lua/plugins/multi.lua`).
--
-- NOTE: `vim.keymap.del` throws when the mapping does not exist, hence the
-- `pcall`.
pcall(vim.keymap.del, "n", "<S-h>")
pcall(vim.keymap.del, "n", "<S-l>")
vim.keymap.set("n", "H", "H", { desc = "Move to top of screen" })
vim.keymap.set("n", "L", "L", { desc = "Move to bottom of screen" })

vim.keymap.set("n", "g\\", function()
	local lines = {}
	for _ = 1, vim.v.count1 do
		lines[#lines + 1] = ""
	end
	local row = vim.api.nvim_win_get_cursor(0)[1]
	vim.api.nvim_buf_set_lines(0, row, row, false, lines)
end, { silent = true, desc = "Put blank line(s) below" })

vim.keymap.set("n", "g/", function()
	local count = vim.v.count1
	local lines = {}
	for _ = 1, count do
		lines[#lines + 1] = ""
	end
	local row = vim.api.nvim_win_get_cursor(0)[1]
	vim.api.nvim_buf_set_lines(0, row, row, false, lines)
	vim.api.nvim_win_set_cursor(0, { row + count, 0 })
end, { silent = true, desc = "Put blank line(s) below and jump to last" })

local function jump_todo(direction)
	local regex = [[\v<(TODO|FIXME|HACK)\c]]
	local flags = direction == "next" and "w" or "bw"
	local start_pos = vim.fn.getpos(".")
	local seen = {}

	while true do
		local stop_line = vim.fn.search(regex, flags)

		if stop_line == 0 then
			break
		end

		local cur = vim.fn.getpos(".")
		local key = cur[2] .. "," .. cur[3]

		if seen[key] then
			vim.fn.setpos(".", start_pos)
			break
		end
		seen[key] = true

		local node = vim.treesitter.get_node()
		if node and node:type():find("comment") then
			break
		end
	end
end

vim.keymap.set("n", "]o", function()
	jump_todo("next")
end, { silent = true, desc = "Next todo comment" })

vim.keymap.set("n", "[o", function()
	jump_todo("prev")
end, { silent = true, desc = "Prev todo comment" })

-- Compile & run the current C++ file.
--
-- The command is built so that the binary is produced next to the source
-- file and executed with a relative `./<name>` path; the terminal therefore
-- runs with `cwd` set to the directory of the buffer, which keeps the
-- relative path valid even when the file lives outside of nvim's cwd.
--
-- NOTE: the key used to be `<leader>cr`, which is LazyVim's *LSP rename*.
-- The two mappings silently fought over the key and the rename was
-- unreachable; the compile & run moved to `<leader>cx` so that both work.
vim.keymap.set("n", "<leader>cx", function()
	if vim.bo.filetype ~= "cpp" then
		vim.notify("Compile & Run only works for C++ files", vim.log.levels.WARN)
		return
	end

	vim.cmd("w")

	local current_file = vim.fn.expand("%:p")
	local file_dir = vim.fn.fnamemodify(current_file, ":h")
	local output_binary = vim.fn.fnamemodify(current_file, ":t:r")

	Snacks.terminal.open(
		"g++ -O3 -std=c++20 -Wall " .. current_file .. " -o " .. output_binary .. " && ./" .. output_binary,
		{
			cwd = file_dir,
			win = { position = "right", width = 0.25 },
		}
	)
end, { desc = "Compile and Run CP File" })


