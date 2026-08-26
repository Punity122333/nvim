local COLOR_BG_PRIMARY = "#1a1b26"
local COLOR_BG_SELECTION = "#28344a"
local COLOR_FG_MARKDOWN_BOLD = "#ff9e64"
local COLOR_UNUSED_DIAGNOSTIC = "#6c7086"
local COLOR_CURSOR_FG = "#000000"
local COLOR_CURSOR_BG = "#00ff00"
local FLAG_FORCE_ALL = os.getenv("NO_LAZY") == "1"

vim.g.python3_host_prog = vim.fn.expand("~/.local/share/molten/venv/bin/python")
if vim.loader then
  vim.loader.enable()
end
do
	local home = vim.fn.expand("~")
	vim.env.PATH = table.concat({
		home .. "/.npm-global/bin",
		home .. "/.local/bin",
		home .. "/.local/share/nvim/mason/bin",
		vim.env.PATH,
	}, ":")
	local lr = home .. "/.luarocks"
	package.path = package.path .. ";" .. lr .. "/share/lua/5.1/?/init.lua;" .. lr .. "/share/lua/5.1/?.lua;"
	package.cpath = package.cpath .. ";" .. lr .. "/lib/lua/5.1/?.so;"
end
local orig_ts_start = vim.treesitter.start
---@diagnostic disable-next-line: duplicate-set-field
vim.treesitter.start = function(buf, lang)
	buf = buf or vim.api.nvim_get_current_buf()
	if vim.bo[buf].filetype:match("^snacks_") then
		vim.bo[buf].syntax = "on"
		return
	end
	orig_ts_start(buf, lang)
end

local ok, rm = pcall(require, "render-markdown")
if ok then
	local orig_rm_attach = rm.attach
	rm.attach = function(buf)
		buf = buf or vim.api.nvim_get_current_buf()
		if vim.bo[buf].filetype:match("^snacks_") then
			return
		end
		orig_rm_attach(buf)
	end
end
vim.opt.relativenumber = true
vim.opt.number = true
vim.opt.concealcursor = ""
vim.g.VM_THEME = ""
vim.g.VM_SET_STATUSLINE = 0

if vim.fn.has("wayland") == 1 then
	vim.g.clipboard = {
		name = "wl-clipboard",
		copy = { ["+"] = "wl-copy", ["*"] = "wl-copy" },
		paste = { ["+"] = "wl-paste", ["*"] = "wl-paste" },
		cache_enabled = 1,
	}
end

require("config.lazy")
require("config.highlights")

vim.defer_fn(function()
	pcall(require, "lspconfig")
	local ft = vim.bo.filetype
	if not FLAG_FORCE_ALL and ft ~= "" and ft ~= "lazy" and ft ~= "dashboard" then
		vim.cmd("doautocmd BufEnter")
	end
end, 300)

vim.keymap.set("n", "hi", ":Inspect<CR>")
vim.api.nvim_create_user_command("RefreshAll", "bufdo edit!", { desc = "Reload all buffers from disk" })

vim.api.nvim_create_user_command("Format", function(args)
	require("conform").format({
		async = true,
		lsp_fallback = true,
		range = args.count ~= -1 and { start = { args.line1, 0 }, ["end"] = { args.line2, 0 } } or nil,
	})
end, { range = true })

local orig_notify = vim.notify
---@diagnostic disable-next-line: duplicate-set-field
vim.notify = function(msg, level, opts)
	if type(msg) == "string" and msg:find("Avante") then
		return
	end
	orig_notify(msg, level, opts)
end

local PROTECTED_PATTERNS = {
	"Border",
	"Prompt",
	"Visual",
	"CursorLine",
	"Search",
	"Pmenu",
	"Cmp",
	"Blink",
	"Float",
	"Kind",
	"Menu",
	"Wild",
	"Noice",
	"Lsp",
	"LSP",
	"lsp",
	"Msg",
	"Diagnostic",
	"lualine",
	"StatusLine",
	"Completion",
	"completion",
	"snippet",
	"Snippet",
	"NormalFloat",
	"Muted",
	"Text",
	"Avante",
	"Ask",
	"VM",
	"Rainbow",
	"LazyReason",
	"TroubleCounts",
	"GitSign",
	"Dap",
}

local function is_protected(name)
	for _, p in ipairs(PROTECTED_PATTERNS) do
		if name:find(p, 1, true) then
			return true
		end
	end
	return false
end

local SELECTION_NAMES = { SnacksPickerCursorLine = true, TelescopeSelection = true, CursorLine = true }

local function apply_theme()
	local set = vim.api.nvim_set_hl

	for name, hl in pairs(vim.api.nvim_get_hl(0, {})) do
		if not hl.bg then
			goto continue
		end

		local is_ui_selection = SELECTION_NAMES[name]
			or (
				name:find("Selected", 1, true)
				and (name:find("SnacksPicker", 1, true) or name:find("Telescope", 1, true))
			)

		if is_ui_selection then
			set(0, name, { bg = COLOR_BG_SELECTION, fg = hl.fg, force = true })
			goto continue
		end

		if
			name:find("@markup", 1, true)
			or name:find("@markdown", 1, true)
			or name:find("@conceal", 1, true)
			or name:find("@spell", 1, true)
		then
			set(0, name, { bg = "NONE", fg = hl.fg, bold = true, force = true })
			goto continue
		end

		if is_protected(name) then
			goto continue
		end

		local bg = COLOR_BG_PRIMARY
		if
			name:find("BlinkCmpKind", 1, true)
			or (name:find("SnacksPicker", 1, true) and not name:find("Selected", 1, true))
			or name:find("Profiler", 1, true)
			or name:find("Benchmark", 1, true)
		then
			bg = "NONE"
		end

		set(0, name, { bg = bg, fg = hl.fg, blend = 0, force = true })
		::continue::
	end

	set(0, "SnacksPickerSelected", { bg = "NONE", fg = "#27a1b9", force = true })
	set(0, "SnacksPickerUnselected", { bg = "NONE", force = true })

	set(0, "Cursor", { fg = COLOR_CURSOR_FG, bg = COLOR_CURSOR_BG, bold = true })
	set(0, "CursorInsert", { fg = COLOR_CURSOR_FG, bg = COLOR_CURSOR_BG })

	for _, g in ipairs({ "Error", "Warn", "Info", "Hint", "Ok" }) do
		local existing = vim.api.nvim_get_hl(0, { name = "DiagnosticUnderline" .. g })
		set(0, "DiagnosticUnderline" .. g, { sp = existing.sp, underline = true, bg = "NONE", force = true })
	end
	set(0, "DiagnosticUnnecessary", { fg = COLOR_UNUSED_DIAGNOSTIC, strikethrough = true, force = true })

	for _, g in ipairs({ "LspReferenceText" }) do
		set(0, g, { bg = COLOR_BG_SELECTION, force = true })
	end
	set(0, "LspReferenceRead", { bg = "NONE", force = true })
	set(0, "LspReferenceWrite", { bg = "NONE", force = true })

	set(0, "MarkdownBold", { fg = COLOR_FG_MARKDOWN_BOLD, bold = true, force = true })
	set(0, "@markup.strong", { fg = COLOR_FG_MARKDOWN_BOLD, bold = true, force = true })

	set(0, "BlinkCmpKindFile", { bg = "NONE", force = true })
	set(0, "LspKindFile", { bg = "NONE", force = true })
	set(0, "BlinkCmpSignatureHelpBorder", { fg = "#27a1b9", bg = COLOR_BG_PRIMARY, force = true })
	set(0, "BlinkCmpSignatureHelp", { bg = COLOR_BG_PRIMARY, force = true })
	set(0, "BlinkCmpSignatureActiveParameter", { bg = COLOR_BG_PRIMARY, force = true })

	set(0, "StatusLine", { bg = "#16161e", force = true })
	set(0, "StatusLineNC", { bg = "#16161e", force = true })

	set(0, "RgPreviewLine", { bg = "#7aa2f7", fg = "#1a1b26", bold = true })
	set(0, "RgPreviewLineCur", { bg = "#e07840", fg = "#1a1b26", bold = true })
	set(0, "SnacksBackdrop", { bg = "#1a1b26", blend = 0, force = true })

	vim.api.nvim_set_hl(0, "MiniSnippetsCurrent", { blend = 100 })
	vim.api.nvim_set_hl(0, "MiniSnippetsVisited", { blend = 100 })
	vim.api.nvim_set_hl(0, "MiniSnippetsUnvisited", { blend = 100 })
	set(0, "NavPreviewLine", { bg = COLOR_BG_PRIMARY, force = true })
end
-- Hi man this is a test comment!
vim.api.nvim_create_autocmd({ "ColorScheme", "VimEnter" }, {
	group = vim.api.nvim_create_augroup("ThemeGodMode", { clear = true }),
	callback = apply_theme,
})

apply_theme()

vim.filetype.add({
	extension = {
		regex = "regex",
	},
})
vim.opt.formatoptions:remove({ "o", "r" })
vim.opt.paste = false
vim.opt.autoindent = false
vim.opt.smartindent = false
vim.opt.cindent = false

vim.g.copilot_debug = 1

