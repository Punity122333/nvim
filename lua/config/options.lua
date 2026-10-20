vim.ui.open = function(path)
	vim.fn.jobstart({ "xdg-open", path }, { detach = true })
end

local COLOR_SIGNATURE_BG = "#15151c"
local COLOR_SIGNATURE_BORDER = "#232330"
local COLOR_ALPHA_HEADER = "#7aa2f7"
local COLOR_ALPHA_BUTTONS = "#bb9af7"
local COLOR_ALPHA_SHORTCUT = "#ff9e64"
local COLOR_ALPHA_FOOTER = "#565f89"
local HIGHLIGHT_NONE = "none"
local BORDER_ROUNDED = "rounded"
local WINHIGHLIGHT_SIGNATURE = "Normal:BlinkCmpSignatureHelp,FloatBorder:BlinkCmpSignatureHelpBorder"
local KITTY_SCROLLBACK_NVIM = "KITTY_SCROLLBACK_NVIM"
local TRUE = "true"
local NPM_GLOBAL_BIN = "~/.npm-global/bin:"
local LOCAL_BIN = "~/.local/bin:"
local MASON_BIN = "~/.local/share/nvim/mason/bin:"

vim.opt.timeoutlen = 300
vim.opt.ttimeoutlen = 10
vim.g.autoformat = false
local orig_util_open_floating_preview = vim.lsp.util.open_floating_preview
function vim.lsp.util.open_floating_preview(contents, syntax, opts, ...)
	opts = opts or {}
	opts.border = opts.border or BORDER_ROUNDED
	local bufnr, winnr = orig_util_open_floating_preview(contents, syntax, opts, ...)
	if winnr and vim.api.nvim_win_is_valid(winnr) then
		vim.api.nvim_set_option_value("winhighlight", WINHIGHLIGHT_SIGNATURE, { win = winnr })
	end
	return bufnr, winnr
end

vim.api.nvim_create_autocmd({ "ColorScheme", "VimEnter" }, {
	pattern = "*",
	callback = function()
		local hl = vim.api.nvim_set_hl
		-- NOTE: this used to be
		--   require("lspconfig.ui.windows").default_options.border = BORDER_ROUNDED
		-- That `require` made lazy.nvim load nvim-lspconfig *immediately*,
		-- in the middle of the LazyVim plugin's own setup, so LazyVim's
		-- nvim-lspconfig `config` never ran: no mason-lspconfig, no
		-- `servers["*"]` capabilities and none of LazyVim's LSP keymaps
		-- (gr, gI, gy, gK, <leader>cr, <leader>co, ]] , [[ , ...).
		-- On top of that `lspconfig.ui.windows` is a stub in
		-- nvim-lspconfig v2 (the float handling moved into Neovim core),
		-- so the assignment was a no-op anyway. The rounded border is
		-- applied by the `vim.lsp.util.open_floating_preview` wrapper
		-- above.
		hl(0, "NormalNC", { bg = HIGHLIGHT_NONE })
		hl(0, "NormalFloat", { bg = HIGHLIGHT_NONE })
		hl(0, "FloatShadow", { bg = HIGHLIGHT_NONE })
		hl(0, "FloatShadowThrough", { bg = HIGHLIGHT_NONE })
		hl(0, "SignColumn", { bg = HIGHLIGHT_NONE })
		hl(0, "LineNr", { bg = HIGHLIGHT_NONE })
		hl(0, "EndOfBuffer", { bg = HIGHLIGHT_NONE })
		hl(0, "StatusLine", { bg = HIGHLIGHT_NONE })
		hl(0, "StatusLineNC", { bg = HIGHLIGHT_NONE })

		hl(0, "SnacksScratch", { bg = HIGHLIGHT_NONE })
		hl(0, "SnacksBackdrop", { bg = HIGHLIGHT_NONE })
		hl(0, "BlinkCmpSignatureHelp", { bg = COLOR_SIGNATURE_BG, blend = 0 })
		hl(0, "BlinkCmpSignatureHelpBorder", { bg = COLOR_SIGNATURE_BG, fg = COLOR_SIGNATURE_BORDER, blend = 0 })
		hl(0, "BlinkCmpSignatureHelpActiveParameter", { bg = COLOR_SIGNATURE_BG, bold = true, blend = 0 })
		hl(0, "LspInfoBorder", { bg = COLOR_SIGNATURE_BG, fg = COLOR_SIGNATURE_BORDER, blend = 0 })
	end,
})

vim.g.lazygit_config = false
vim.api.nvim_create_autocmd("User", {
	pattern = "AlphaReady",
	callback = function()
		local hl = vim.api.nvim_set_hl
		hl(0, "AlphaHeader", { fg = COLOR_ALPHA_HEADER })
		hl(0, "AlphaButtons", { fg = COLOR_ALPHA_BUTTONS })
		hl(0, "AlphaShortcut", { fg = COLOR_ALPHA_SHORTCUT })
		hl(0, "AlphaFooter", { fg = COLOR_ALPHA_FOOTER })
	end,
})

if vim.env[KITTY_SCROLLBACK_NVIM] == TRUE then
	vim.g.loaded_matchit = 1
	vim.g.loaded_netrwPlugin = 1
end

vim.opt.foldenable = true
vim.env.PATH = vim.fn.expand(NPM_GLOBAL_BIN) .. vim.env.PATH
vim.env.PATH = vim.fn.expand(LOCAL_BIN) .. vim.env.PATH
vim.env.PATH = vim.fn.expand(MASON_BIN) .. vim.env.PATH
vim.opt.relativenumber = true
vim.opt.number = true

vim.opt.wrap = false
vim.opt.sidescrolloff = 8
vim.opt.scrolloff = 8

vim.opt.list = false
vim.opt.concealcursor = ""
-- Indentation: one level is `INDENT_WIDTH` columns everywhere (see
-- `lua/config/indent_width.lua`). LazyVim loads its own defaults
-- (shiftwidth=2/tabstop=2) *before* this file, so these win.
local INDENT_WIDTH = require("config.indent_width").width
vim.opt.expandtab = true
vim.opt.shiftwidth = INDENT_WIDTH
vim.opt.tabstop = INDENT_WIDTH
vim.opt.softtabstop = INDENT_WIDTH
vim.o.winborder = BORDER_ROUNDED
vim.g.loaded_matchparen = 1
vim.opt.shortmess:append("S")
vim.opt.hlsearch = false
vim.g.vimtex_syntax_conceal = {
	additions = 0,
	consecutive_stops = 0,
	definitions = 0,
	delimited = 0,
	greek = 0,
	math_bounds = 0,
	math_delimiters = 0,
	math_fracs = 0,
	math_symbols = 0,
	math_super_sub = 0,
	sections = 0,
	styles = 0,
}

-- NOTE: `g:clipboard` used to be set here as well as in `init.lua`.
-- This one was unconditional, so it pointed Neovim at the `wl-copy`
-- binaries even on systems that do not have them. The Wayland-only
-- version in `init.lua` is the one that is kept.

vim.g.vimtex_syntax_conceal_disable = 1

vim.opt.spell = false

vim.opt.updatetime = 400

vim.opt.signcolumn = "no"

-- ── helpers ────────────────────────────────────────────────────────────────
local EMPTY = "%#SignColumn#  "

local _ns_cache = {}
local _diag_txt = {}
local _lc_buf = nil
local _lc_tick = nil
local _lc_width = 2

local function get_ns(name)
	if not _ns_cache[name] then
		local id = vim.api.nvim_get_namespaces()[name]
		if id then
			_ns_cache[name] = id
		end
	end
	return _ns_cache[name]
end

local function line_width(buf)
	local tick = vim.api.nvim_buf_get_changedtick(buf)
	if buf ~= _lc_buf or tick ~= _lc_tick then
		local count = vim.api.nvim_buf_line_count(buf)
		_lc_buf = buf
		_lc_tick = tick
		_lc_width = math.max(#tostring(count), 2)
	end
	return _lc_width
end

local function diag_text(sev_name)
	local cached = _diag_txt[sev_name]
	if cached then
		return cached
	end
	local txt
	if sev_name == "Error" or sev_name == "Warn" or sev_name == "Info" or sev_name == "Hint" then
		local def = vim.fn.sign_getdefined("DiagnosticSign" .. sev_name)[1]
		txt = (def and def.text) or (sev_name:sub(1, 1) .. " ")
	else
		txt = sev_name:sub(1, 1) .. " "
	end
	_diag_txt[sev_name] = txt
	return txt
end

local function extmark_sign(ns_name, buf, lnum)
	local ns = get_ns(ns_name)
	if not ns then
		return EMPTY
	end
	local ok, ems = pcall(vim.api.nvim_buf_get_extmarks, buf, ns, { lnum - 1, 0 }, { lnum - 1, -1 }, { details = true })
	if ok and ems[1] then
		local d = ems[1][4]
		if d and d.sign_text and d.sign_text ~= "" then
			return "%#" .. (d.sign_hl_group or "SignColumn") .. "#" .. d.sign_text
		end
	end
	return EMPTY
end

local function diag_sign(buf, lnum)
	local diags = vim.diagnostic.get(buf, { lnum = lnum - 1 })
	if #diags == 0 then
		return EMPTY
	end
	local sev = diags[1].severity
	for _, d in ipairs(diags) do
		if d.severity < sev then
			sev = d.severity
		end
	end
	local sev_name = ({
		[vim.diagnostic.severity.ERROR] = "Error",
		[vim.diagnostic.severity.WARN] = "Warn",
		[vim.diagnostic.severity.INFO] = "Info",
		[vim.diagnostic.severity.HINT] = "Hint",
	})[sev]
	if not sev_name then
		return EMPTY
	end
	local txt = diag_text(sev_name)
	return "%#DiagnosticSign" .. sev_name .. "#" .. txt
end

local function make_number(buf, lnum)
	local num = (vim.wo.relativenumber and vim.v.relnum ~= 0) and vim.v.relnum or lnum
	local num_hl = vim.v.relnum == 0 and "%#CursorLineNr#" or "%#LineNr#"
	local width = line_width(buf)
	return num_hl .. " " .. string.format("%" .. width .. "d", num) .. " "
end

_G.StatusColumn = function()
	local buf = vim.api.nvim_get_current_buf()
	local lnum = vim.v.lnum
	return extmark_sign("dap_breakpoints", buf, lnum)
		.. diag_sign(buf, lnum)
		.. extmark_sign("MarkSigns", buf, lnum)
		.. make_number(buf, lnum)
		.. extmark_sign("gitsigns_signs_", buf, lnum)
end

-- `StatusColumnSimple` is evaluated for *every rendered line*, so the
-- work it does is cached:
--   * the list of namespaces (it only changes when a plugin is loaded),
--   * the namespaces that actually have marks in the buffer, refreshed
--     at most every 500ms so new signs show up quickly.
local _sc_namespaces = nil
local _sc_candidates = {} ---@type table<integer, { ns: integer[], at: number }>

vim.api.nvim_create_autocmd("User", {
	pattern = "LazyLoad",
	desc = "statuscolumn: invalidate the namespace cache",
	callback = function()
		_sc_namespaces = nil
	end,
})

---@return integer[]
local function sc_namespaces()
	if not _sc_namespaces then
		_sc_namespaces = {}
		for ns_name, ns_id in pairs(vim.api.nvim_get_namespaces()) do
			-- gitsigns has its own column, it is added separately
			if ns_name ~= "gitsigns_signs_" then
				_sc_namespaces[#_sc_namespaces + 1] = ns_id
			end
		end
	end
	return _sc_namespaces
end

---@param buf integer
---@return integer[]
local function sc_candidates(buf)
	local now = vim.uv.hrtime()
	local cached = _sc_candidates[buf]
	if cached and (now - cached.at) < 500 * 1000000 then
		return cached.ns
	end

	local ns = {}
	for _, ns_id in ipairs(sc_namespaces()) do
		if #vim.api.nvim_buf_get_extmarks(buf, ns_id, 0, -1, {}) > 0 then
			ns[#ns + 1] = ns_id
		end
	end

	_sc_candidates[buf] = { ns = ns, at = now }
	return ns
end

_G.StatusColumnSimple = function()
	local buf = vim.api.nvim_get_current_buf()
	local lnum = vim.v.lnum
	local sign_col = EMPTY
	local best_p = -1
	for _, ns_id in ipairs(sc_candidates(buf)) do
		local ok, ems = pcall(
			vim.api.nvim_buf_get_extmarks,
			buf,
			ns_id,
			{ lnum - 1, 0 },
			{ lnum - 1, -1 },
			{ details = true }
		)
		if ok then
			for _, em in ipairs(ems) do
				local d = em[4]
				if d and d.sign_text and d.sign_text ~= "" and (d.priority or 0) > best_p then
					best_p = d.priority or 0
					sign_col = "%#" .. (d.sign_hl_group or "SignColumn") .. "#" .. d.sign_text
				end
			end
		end
	end
	return sign_col .. make_number(buf, lnum) .. extmark_sign("gitsigns_signs_", buf, lnum)
end

-- ── toggle ─────────────────────────────────────────────────────────────────
local _sc_enabled = false

-- The statuscolumn template and `signcolumn` are global options, so
-- they are only written when they actually change (see `set_sc_global`),
-- not on every BufEnter.
--
-- NOTE: the template is kept in a variable because `vim.opt.statuscolumn`
-- returns a list proxy, not the value.
local _sc_template = nil

local function set_sc_global()
	_sc_template = _sc_enabled and "%{%v:lua.StatusColumn()%}" or "%{%v:lua.StatusColumnSimple()%}"
	vim.opt.signcolumn = "no"
	vim.opt.statuscolumn = _sc_template
end

-- Buffers that should not show a status column at all.
local SC_EXCLUDE = {
	"NvimTree",
	"neo-tree",
	"oil",
	"stevearc.oil",
	"lazy",
	"mason",
	"trouble",
	"dashboard",
	"alpha",
	"snacks_dashboard",
	"starter",
	"help",
	"man",
	"checkhealth",
	"tutor",
	"dapui_scopes",
	"dapui_breakpoints",
	"dapui_stacks",
	"dapui_watches",
	"dapui_console",
	"dap-repl",
	"dap-terminal",
	"avante",
	"avante-input",
	"avante-selected",
	"avante-chat",
	"Avante",
	"notify",
	"noice",
	"snacks_notif",
	"snacks_notif_history",
	"snacks_win_backdrop",
	"TelescopePrompt",
	"TelescopeResults",
	"qf",
	"gitcommit",
	"git",
	"diff",
	"toggleterm",
	"undotree",
}

local function init_sc()
	local ft = vim.bo.filetype
	local bt = vim.bo.buftype

	if bt == "nofile" or bt == "prompt" then
		if ft:find("dap") then
			if ft:find("float") then
				vim.opt_local.statuscolumn = ""
				vim.opt_local.number = false
				vim.opt_local.relativenumber = false
				return
			else
				vim.opt_local.statuscolumn = "   "
				vim.opt_local.number = false
				vim.opt_local.relativenumber = false
				return
			end
		else
			vim.opt_local.statuscolumn = ""
			vim.opt_local.number = false
			vim.opt_local.relativenumber = false
			return
		end
	end

	if ft:find("Avante") then
		vim.opt_local.statuscolumn = ""
		vim.opt_local.number = false
		vim.opt_local.relativenumber = false
		return
	end
	if ft:find("^snacks_") then
		vim.opt_local.statuscolumn = " "
		vim.opt_local.number = false
		vim.opt_local.relativenumber = false
		return
	end
	if ft:find("dap") then
		vim.opt_local.statuscolumn = "   "
		vim.opt_local.number = false
		vim.opt_local.relativenumber = false
		return
	end
	if vim.tbl_contains(SC_EXCLUDE, ft) or ft:find("avante") then
		vim.opt_local.statuscolumn = " "
		vim.opt_local.number = false
		vim.opt_local.relativenumber = false
		return
	end

	-- a normal buffer: use the global template and show the numbers.
	-- The local value has to be reset, because a buffer that was e.g. a
	-- `nofile` buffer before still carries the old local override.
	vim.opt_local.statuscolumn = _sc_template
	vim.opt_local.number = true
	vim.opt_local.relativenumber = true
end
set_sc_global()
init_sc()

vim.keymap.set("n", "<leader>Us", function()
	_sc_enabled = not _sc_enabled
	set_sc_global()
	for _, win in ipairs(vim.api.nvim_list_wins()) do
		local cfg = vim.api.nvim_win_get_config(win)
		-- Skip floating windows (fold panels and others)
		if cfg.relative == "" then
			vim.api.nvim_win_call(win, init_sc)
		end
	end
	vim.notify(
		_sc_enabled and "Custom signcolumn enabled" or "Simple signcolumn enabled",
		vim.log.levels.INFO,
		{ title = "UI Toggle" }
	)
end, { desc = "Toggle signcolumn (all windows)" })

vim.api.nvim_create_autocmd({ "BufEnter", "FileType" }, {
	callback = function()
		init_sc()
	end,
})
vim.opt.ttyfast = true
vim.opt.swapfile = false
vim.opt.clipboard = ""
vim.opt.conceallevel = 3
vim.opt.concealcursor = "nvc"
vim.api.nvim_set_hl(0, "SnippetsTabstop", { fg = "NONE", bg = "NONE", blend = 100 })
vim.api.nvim_set_hl(0, "SnippetsPlaceholder", { fg = "NONE", bg = "NONE", blend = 100 })
