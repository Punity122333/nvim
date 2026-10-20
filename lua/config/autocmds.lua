local COLOR_LINE_NUMBER = "#565f89"
local COLOR_NONE = "none"
require("config.clauseclose")
require("config.react_indent").setup()
vim.api.nvim_set_hl(0, "SignColumn", { bg = COLOR_NONE })
vim.api.nvim_set_hl(0, "LineNr", { fg = COLOR_LINE_NUMBER, bg = COLOR_NONE })
vim.api.nvim_set_hl(0, "EndOfBuffer", { fg = COLOR_NONE, bg = COLOR_NONE })

local codeaction_timers = {}
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
	callback = function(args)
		vim.cmd("redraw!")
		vim.api.nvim_set_current_buf(args.buf)
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

vim.api.nvim_create_autocmd({ "BufReadPost", "BufNewFile" }, {
	callback = function(args)
		if vim.api.nvim_buf_line_count(args.buf) > 5000 then
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

vim.api.nvim_create_autocmd("FileType", {
	pattern = {
		"cpp",
		"c",
		"hpp",
		"h",
		"rust",
		"go",
		"zig",
		"cuda",
		"asm",
		"nasm",
		"objc",
		"objcpp",
		"swift",
		"fortran",
		"verilog",
		"vhdl",
		"julia",
		"prolog",
		"ocaml",
		"erlang",
		"haskell",
		"clojure",
		"elixir",
		"fsharp",
		"lisp",
		"scheme",
		"racket",
		"coq",
		"idris",
		"kotlin",
		"dart",
		"java",
		"scala",
		"groovy",
		"android",
		"python",
		"lua",
		"ruby",
		"perl",
		"php",
		"nim",
		"tcl",
		"r",
		"javascript",
		"typescript",
		"typescriptreact",
		"javascriptreact",
		"html",
		"css",
		"scss",
		"sass",
		"less",
		"vue",
		"svelte",
		"astro",
		"graphql",
		"solidity",
		"json",
		"jsonc",
		"yaml",
		"toml",
		"xml",
		"ron",
		"sql",
		"csv",
		"tsv",
		"dhall",
		"sh",
		"bash",
		"zsh",
		"fish",
		"cmake",
		"make",
		"just",
		"ninja",
		"dockerfile",
		"makefile",
		"conf",
		"config",
		"ini",
		"bitbake",
		"markdown",
		"latex",
		"tex",
		"bib",
		"org",
		"rst",
		"typst",
		"asciidoc",
		"terraform",
		"hcl",
		"k8s",
		"docker-compose",
		"nginx",
		"sshconfig",
		"gitconfig",
		"gitignore",
		"helm",
		"hyprlang",
		"kitty",
		"waybar",
		"xdefaults",
		"desktop",
		"tmux",
		"nix",
		"desktop",
	},
	callback = function()
		local ft = vim.bo.filetype
		local bufname = vim.api.nvim_buf_get_name(0):lower()
     
		if
			vim.bo.buftype == ""
			and ft ~= ""
			and not ft:find("snacks")
			and not ft:find("avante")
			and not ft:find("grug%-far")
			and not bufname:find("avante")
			and not bufname:find("grug%-far")
		then
			local buf = vim.api.nvim_get_current_buf()
			vim.schedule(function()
				if not vim.api.nvim_buf_is_valid(buf) then
					return
				end
				local keys = vim.api.nvim_replace_termcodes("a<Esc>", true, false, true)
				vim.api.nvim_feedkeys(keys, "n", false)
			end)
		end
	end,
})

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
			vim.cmd("redraw!")
			vim.cmd("")
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

local function highlight_cursor_char()
	local bufnr = vim.api.nvim_get_current_buf()
	local pos = vim.api.nvim_win_get_cursor(0)
	local row, col = pos[1] - 1, pos[2]

	if bufnr == _cb_buf and row == _cb_row and col == _cb_col then
		return
	end
	_cb_buf = bufnr
	_cb_row = row
	_cb_col = col

	local line_content = vim.api.nvim_buf_get_lines(bufnr, row, row + 1, false)[1] or ""
	local line_len = #line_content

	if line_len == 0 or line_len > 1000 or col >= line_len then
		vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)
		return
	end

	vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)
	vim.api.nvim_buf_set_extmark(bufnr, ns, row, col, {
		end_col = col + 1,
		hl_group = "CursorBoldChar",
		strict = false,
	})
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
