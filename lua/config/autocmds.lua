local COLOR_LINE_NUMBER = "#565f89"
local COLOR_NONE = "none"
require("config.clauseclose")
require("config.react_indent").setup()
vim.api.nvim_set_hl(0, "SignColumn", { bg = COLOR_NONE })
vim.api.nvim_set_hl(0, "LineNr", { fg = COLOR_LINE_NUMBER, bg = COLOR_NONE })
vim.api.nvim_set_hl(0, "EndOfBuffer", { fg = COLOR_NONE, bg = COLOR_NONE })

local codeaction_timers = {}
-- The key of the diagnostics that were last asked for, per buffer.
--
-- NOTE: the request itself is thrown away (the callback does nothing with
-- the result), so it is only sent when the diagnostics under the cursor
-- actually changed.  Asking the server on *every* cursor stop was pure
-- overhead - and the answer came back right when the user stopped moving
-- the cursor, which is exactly when a repaint is the most noticeable.
local codeaction_state = {}
vim.api.nvim_create_autocmd("LspAttach", {
	callback = function(args)
		local client = vim.lsp.get_client_by_id(args.data.client_id)
		if not client then
			return
		end

		if client.offset_encoding then
			client.offset_encoding = "utf-16"
		end

		if not client.server_capabilities.codeActionProvider then
			return
		end

		local excluded_servers = { html = true, cssls = true, eslint = true, ["crates.nvim"] = true }
		if excluded_servers[client.name] then
			return
		end

		vim.api.nvim_create_autocmd("CursorHold", {
			buffer = args.buf,
			callback = function()
				if vim.fn.mode() ~= "n" then
					return
				end
				if codeaction_timers[args.buf] then
					vim.fn.timer_stop(codeaction_timers[args.buf])
					codeaction_timers[args.buf] = nil
				end

				codeaction_timers[args.buf] = vim.fn.timer_start(300, function()
					codeaction_timers[args.buf] = nil
					if vim.fn.mode() ~= "n" then
						return
					end
					if not vim.api.nvim_buf_is_valid(args.buf) then
						return
					end
					local params = vim.lsp.util.make_range_params(nil, "utf-16")

					params.context = { diagnostics = vim.diagnostic.get(args.buf, { lnum = vim.fn.line(".") - 1 }) }

					-- Nothing changed since the last request: the server
					-- would answer with the same actions.
					local key = table.concat(
						vim.tbl_map(function(d)
							return table.concat({ d.severity, d.code, d.lnum, d.col, d.source }, ":")
						end, params.context.diagnostics),
						"|"
					)
					if codeaction_state[args.buf] == key then
						return
					end
					codeaction_state[args.buf] = key

					vim.lsp.buf_request(
						args.buf,
						"textDocument/codeAction",
						params,
						---@diagnostic disable-next-line: unused-local
						function(err, result, ctx, config) end
					)
				end)
			end,
		})
		vim.api.nvim_create_autocmd("BufDelete", {
			buffer = args.buf,
			once = true,
			callback = function()
				if codeaction_timers[args.buf] then
					pcall(vim.fn.timer_stop, codeaction_timers[args.buf])
					codeaction_timers[args.buf] = nil
				end
			end,
		})
	end,
})

vim.api.nvim_create_autocmd("FileType", {
	pattern = { "avante", "avante-input" },
	callback = function()
		vim.opt_local.conceallevel = 2
		vim.opt_local.concealcursor = "nc"
	end,
})

vim.api.nvim_create_autocmd("BufDelete", {
	callback = function(args)
		local ft = vim.bo[args.buf].filetype
		if ft ~= "avante" and ft ~= "avante-input" then
			vim.schedule(function()
				local ok, avante_api = pcall(require, "avante.api")
				if ok and avante_api.refresh then
					pcall(avante_api.refresh)
				else
					vim.cmd("AvanteRefresh")
				end
			end)
		end
	end,
	desc = "Refresh Avante when a code buffer is deleted",
})

---@diagnostic disable-next-line: unused-local
local vm_augroup = vim.api.nvim_create_augroup("VMLagFix", { clear = true })

vim.api.nvim_create_autocmd("FileType", {
	pattern = { "cpp" },
	callback = function()
		-- The C++ syntax is only correct after a redraw, so ask for one.
		--
		-- NOTE: this must not touch the buffer.  The `FileType` event also
		-- fires for the *temporary* buffers that Neovim uses to evaluate a
		-- filetype option (`vim.filetype.get_option()`), and those buffers
		-- are already gone when the callback runs: `nvim_set_current_buf()`
		-- then failed with "Buffer N does not exist".  That error was
		-- raised *inside* the comment operators (they ask for
		-- 'commentstring' that way) and made `gcc` do nothing.
		--
		-- The redraw is scheduled because doing it in the middle of the
		-- event paints a half-finished screen (the old cursor cell stays
		-- visible for a moment - the "ghosting" of the cursor).
		vim.schedule(function()
			vim.cmd("redraw")
		end)
	end,
})

vim.api.nvim_create_autocmd("FileType", {
	pattern = "spectre_panel",
	callback = function()
		vim.opt_local.number = false
		vim.opt_local.relativenumber = false
	end,
})

vim.api.nvim_create_autocmd("FileType", {
	pattern = { "c", "cpp", "h", "hpp" },
	callback = function(args)
		vim.bo[args.buf].cindent = false
		vim.bo[args.buf].smartindent = false
		vim.bo[args.buf].autoindent = true
		-- Hybrid C/C++ indent (treesitter + cindent fallback); ensure
		-- indentexpr is set even if LazyVim's set_default was skipped
		-- (it only sets unset options).
		local iexpr = vim.bo[args.buf].indentexpr
		if iexpr == nil or iexpr == "" then
			vim.bo[args.buf].indentexpr = "v:lua.require'config.cpp_indent'.indentexpr()"
		end
	end,
})

vim.api.nvim_create_autocmd("BufWritePre", {
	callback = function(args)
		local lines = vim.api.nvim_buf_line_count(args.buf)
		if lines > 5000 then
			vim.b.autoformat = false
		end
	end,
})

vim.api.nvim_create_autocmd("LspAttach", {
	callback = function(args)
		local client = vim.lsp.get_client_by_id(args.data.client_id)
		if client and client.name == "rust-analyzer" then
			client.offset_encoding = "utf-8"
		end
	end,
})
local snacks_refresh_group = vim.api.nvim_create_augroup("SnacksExplorerRefresh", { clear = true })
local snacks_refresh_timer = nil
vim.api.nvim_create_autocmd("DiagnosticChanged", {
	group = snacks_refresh_group,
	callback = function()
		if snacks_refresh_timer then
			vim.fn.timer_stop(snacks_refresh_timer)
			snacks_refresh_timer = nil
		end

		snacks_refresh_timer = vim.fn.timer_start(800, function()
			snacks_refresh_timer = nil
			vim.schedule(function()
				local snacks = package.loaded["snacks"]
				if not snacks then
					return
				end

				local explorers = snacks.picker.get({ source = "explorer" })
				if #explorers == 0 then
					return
				end
				for _, picker in ipairs(explorers) do
					picker:find()
				end
			end)
		end)
	end,
})

vim.api.nvim_create_autocmd("FileType", {
	pattern = "avante",
	callback = function()
		vim.opt_local.modifiable = true
	end,
})

-- Parse the buffer right after it was read, so that the tree-sitter queries
-- (folds, indent, ...) have their tree before the first key press.
--
-- NOTE: `parser:parse()` is *synchronous*: it blocks the main loop until the
-- whole buffer is parsed.  For a big file that freezes the UI for a moment
-- and the cursor visibly lags behind (the terminal keeps showing the old
-- screen).  The limit is the same one the tree-sitter config uses for
-- C/C++ files (see `lua/config/treesitter.lua`).
local MAX_PARSE_LINES = 1000

vim.api.nvim_create_autocmd({ "BufReadPost", "BufNewFile" }, {
	callback = function(args)
		if vim.api.nvim_buf_line_count(args.buf) > MAX_PARSE_LINES then
			return
		end
		vim.schedule(function()
			if not vim.api.nvim_buf_is_valid(args.buf) then
				return
			end
			local ok, parser = pcall(vim.treesitter.get_parser, args.buf)
			if ok and parser then
				pcall(parser.parse, parser, true)
			end
		end)
	end,
})

-- The `a<Esc>` hack that used to live here is gone.
--
-- It entered insert mode and left it again right after a file was opened,
-- to "prime" the buffer (see commit 852cefe).  Two things were wrong with
-- it:
--
--   * `nvim_feedkeys()` puts the keys *into the typeahead*, so they end up
--     *between* the keys the user types.  A fast "gcc" was split into
--     "g" + "a<Esc>" + "cc": the "g" got the "a" as its argument, the
--     comment never happened and the leftover "cc" changed the line.  That
--     is why commenting only worked when the keys were typed slowly.
--   * the insert-mode round trip changes the cursor shape (the block
--     cursor becomes the thin insert cursor and back), so the cursor
--     flickered on every file open - that is most of the "ghosting" that
--     was reported.
--
-- The hack did not do anything useful either: it does not evaluate
-- 'indentexpr' and it does not change the buffer.
--
-- If the priming is ever needed again, do it *without* the typeahead
-- (e.g. `vim.api.nvim_exec_autocmds("InsertEnter", ...)`), never with
-- `nvim_feedkeys()`.

vim.api.nvim_create_autocmd("FileType", {
	pattern = { "Avante" },
	callback = function()
		require("blink.cmp").setup({
			enabled = function()
				return false
			end,
		})
	end,
})

vim.api.nvim_create_autocmd("TermOpen", {
	callback = function()
		vim.opt_local.number = false
		vim.opt_local.relativenumber = false
	end,
})

vim.api.nvim_create_autocmd("FileType", {
	pattern = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
	callback = function()
		pcall(function()
			vim.cmd("lsp enable vtsls")
		end)
	end,
})

local function redraw_signs()
	vim.schedule(function()
		vim.schedule(function()
			-- NOTE: `redraw` and not `redraw!`: the bang repaints the whole
			-- screen, which flickers and leaves the cell of the old cursor
			-- position visible for a moment (the "ghosting" of the cursor).
			-- Only the sign column has to be refreshed here.
			vim.cmd("redraw")
		end)
	end)
end

local mark_chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
for i = 1, #mark_chars do
	local c = mark_chars:sub(i, i)
	vim.keymap.set("n", "m" .. c, function()
		vim.cmd("normal! m" .. c)
		redraw_signs()
	end, { silent = true, desc = "Set mark " .. c })
end
vim.fn.sign_define("DapBreakpoint", { text = "●", texthl = "DapBreakpoint", priority = 10 })
vim.fn.sign_define("DapBreakpointCondition", { text = "◆", texthl = "DapBreakpointCondition", priority = 10 })
vim.fn.sign_define("DapBreakpointRejected", { text = "○", texthl = "DapBreakpointRejected", priority = 10 })
vim.fn.sign_define("DapStopped", { text = "▶", texthl = "DapStopped", priority = 10 })
vim.fn.sign_define("DapLogPoint", { text = "◉", texthl = "DapLogPoint", priority = 10 })
vim.diagnostic.config({
	signs = {
		priority = 20,
	},
})

vim.api.nvim_create_autocmd("User", {
	pattern = "MarksSetupComplete",
	once = true,
	callback = function()
		local marks = require("marks")
		if marks.mark_state and marks.mark_state.signs then
			for _, sign in pairs(marks.mark_state.signs) do
				sign.priority = 30
			end
		end
	end,
})
vim.api.nvim_create_autocmd("FocusGained", {
	callback = function()
		vim.defer_fn(function()
			collectgarbage("collect")
		end, 1000)
	end,
})

vim.api.nvim_create_autocmd("FileType", {
	pattern = "dbui",
	callback = function()
		vim.cmd("wincmd L")
		vim.cmd("vertical resize 40")
	end,
})
vim.api.nvim_clear_autocmds({ event = "WinScrolled" })
vim.api.nvim_set_hl(0, "CursorBoldChar", { bold = true })
local ns = vim.api.nvim_create_namespace("cursor_bold_char")
local _cb_buf = nil
local _cb_row = nil
local _cb_col = nil
local _cb_mark = nil

-- Draw the character under the cursor in bold.
--
-- NOTE: this is *off* by default, because it repaints the cell under the
-- cursor *after* the cursor has already moved on.  The terminal caches the
-- cell under the cursor (kitty does, and it also restores that copy when
-- the cursor leaves) - so a cell that is repainted afterwards comes back
-- with the stale content: that was the "ghost" of the old cursor
-- position.
--
-- Set `vim.g.cursor_bold_char = true` to get the bold character back.
local function highlight_cursor_char()
	local bufnr = vim.api.nvim_get_current_buf()

	-- The feature was switched off: remove the mark again.
	if not vim.g.cursor_bold_char then
		if _cb_mark then
			pcall(vim.api.nvim_buf_del_extmark, bufnr, ns, _cb_mark)
			_cb_mark = nil
			_cb_buf = nil
		end
		return
	end

	local pos = vim.api.nvim_win_get_cursor(0)
	local row, col = pos[1] - 1, pos[2]

	if bufnr == _cb_buf and row == _cb_row and col == _cb_col then
		return
	end

	-- Another buffer: the mark of the old buffer is not needed any more.
	if bufnr ~= _cb_buf and _cb_buf and _cb_mark then
		pcall(vim.api.nvim_buf_del_extmark, _cb_buf, ns, _cb_mark)
		_cb_mark = nil
	end

	_cb_buf = bufnr
	_cb_row = row
	_cb_col = col

	local line_content = vim.api.nvim_buf_get_lines(bufnr, row, row + 1, false)[1] or ""
	local line_len = #line_content

	if line_len == 0 or line_len > 1000 or col >= line_len then
		if _cb_mark then
			pcall(vim.api.nvim_buf_del_extmark, bufnr, ns, _cb_mark)
			_cb_mark = nil
		end
		return
	end

	if _cb_mark then
		pcall(vim.api.nvim_buf_set_extmark, bufnr, ns, _cb_mark, row, col, {
			end_col = col + 1,
			hl_group = "CursorBoldChar",
			strict = false,
		})
	else
		_cb_mark = vim.api.nvim_buf_set_extmark(bufnr, ns, row, col, {
			end_col = col + 1,
			hl_group = "CursorBoldChar",
			strict = false,
		})
	end
end

vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
	callback = highlight_cursor_char,
})

vim.api.nvim_create_autocmd("LspAttach", {
	pattern = "Cargo.toml",
	callback = function(ev)
		local client = vim.lsp.get_client_by_id(ev.data.client_id)
		if client and client.name == "taplo" then
			client.server_capabilities.hoverProvider = false
		end
	end,
})
