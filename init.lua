-- NOTE: the palette lives in `config.highlights` so that every colour is
-- defined exactly once.  The aliases are resolved right after that module
-- has been loaded (see the `require` calls further down).

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
		-- ghcup (ghcup, cabal) and cabal's user bin dir. Needed by mason
		-- to install the Haskell language server / debug adapter.
		home .. "/.ghcup/bin",
		home .. "/.cabal/bin",
		vim.env.PATH,
	}, ":")
	local lr = home .. "/.luarocks"
	package.path = package.path .. ";" .. lr .. "/share/lua/5.1/?/init.lua;" .. lr .. "/share/lua/5.1/?.lua;"
	package.cpath = package.cpath .. ";" .. lr .. "/lib/lua/5.1/?.so;"
end
-- rust-analyzer needs the standard library *sources* to resolve `std`
-- items. They ship in the `rust-src` package, which is not installed
-- system-wide here, so without them rust-analyzer does not even know
-- about `println!`, `String` or `Vec` and only completes the primitive
-- types. Point it at a local copy of the sources.
do
	local local_src = vim.fn.expand("~/.local/share/rust-src/usr/lib/rustlib/src/rust/library")
	if vim.uv.fs_stat(local_src) then
		local ok, sysroot = pcall(function()
			return vim.trim(vim.fn.system({ "rustc", "--print", "sysroot" }))
		end)
		-- Prefer the system-wide sources when they are installed.
		if ok and sysroot ~= "" and not vim.uv.fs_stat(sysroot .. "/lib/rustlib/src/rust/library") then
			vim.env.RUST_SRC_PATH = local_src
		end
	end
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

-- NOTE: render-markdown is disabled in `lua/plugins/render-markdown.lua`,
-- so the `rm.attach` patch below could never run. It was removed together
-- with the `require` below, which poked lazy.nvim's module loader on every
-- startup for a plugin that is not installed.

vim.opt.relativenumber = true
vim.opt.number = true
vim.opt.concealcursor = ""

if vim.fn.has("wayland") == 1 then
	vim.g.clipboard = {
		name = "wl-clipboard",
		copy = { ["+"] = "wl-copy", ["*"] = "wl-copy" },
		paste = { ["+"] = "wl-paste", ["*"] = "wl-paste" },
		cache_enabled = 1,
	}
end

require("config.lazy")
local highlights = require("config.highlights")
require("config.indent_predicates").setup()

-- Palette aliases, see the note at the top of this file.
local COLOR_BG_PRIMARY = highlights.colors.background_primary
local COLOR_BG_SELECTION = highlights.colors.selection_blue
local COLOR_FG_MARKDOWN_BOLD = highlights.colors.markdown_bold
local COLOR_UNUSED_DIAGNOSTIC = highlights.colors.unused_diagnostic
local COLOR_CURSOR_FG = highlights.colors.cursor_fg
local COLOR_CURSOR_BG = highlights.colors.cursor_bg

vim.keymap.set("n", "hi", "<cmd>Inspect<cr>", { desc = "Inspect the word under the cursor" })
vim.api.nvim_create_user_command("RefreshAll", "bufdo edit!", { desc = "Reload all buffers from disk" })

vim.api.nvim_create_user_command("Format", function(args)
	require("conform").format({
		async = true,
		lsp_fallback = true,
		range = args.count ~= -1 and { start = { args.line1, 0 }, ["end"] = { args.line2, 0 } } or nil,
	})
end, { range = true })

-- NOTE: there used to be a `vim.notify` override here that swallowed every
-- message containing the word "Avante". It was broken twice over:
--   * it captured `vim.notify` *before* snacks/noice had replaced it, so it
--     captured LazyVim's temporary collector - the queue of pending
--     notifications was then never drained and eventually overflowed
--     ("table overflow");
--   * noice replaced the override again, so it never actually silenced
--     anything - and noice's healthcheck reports the overwrite as an error.
-- Avante's errors and warnings are worth seeing, so nothing is filtered
-- here anymore.

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

	-- Groups owned by `config.highlights` that have to survive the re-tint
	-- loop above (and a colorscheme change).
	highlights.apply_overrides()

	for _, g in ipairs({ "LspReferenceText" }) do
		set(0, g, { bg = COLOR_BG_SELECTION, force = true })
	end
	set(0, "LspReferenceWrite", { bg = "NONE", force = true })

	set(0, "MarkdownBold", { fg = COLOR_FG_MARKDOWN_BOLD, bold = true, force = true })

	set(0, "BlinkCmpKindFile", { bg = "NONE", force = true })
	set(0, "LspKindFile", { bg = "NONE", force = true })

	set(0, "RgPreviewLine", { bg = "#7aa2f7", fg = COLOR_BG_PRIMARY, bold = true })
	set(0, "RgPreviewLineCur", { bg = "#e07840", fg = COLOR_BG_PRIMARY, bold = true })
	set(0, "SnacksBackdrop", { bg = COLOR_BG_PRIMARY, blend = 0, force = true })

	vim.api.nvim_set_hl(0, "MiniSnippetsCurrent", { blend = 100 })
	vim.api.nvim_set_hl(0, "MiniSnippetsVisited", { blend = 100 })
	vim.api.nvim_set_hl(0, "MiniSnippetsUnvisited", { blend = 100 })
	set(0, "NavPreviewLine", { bg = COLOR_BG_PRIMARY, force = true })
end

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
vim.opt.autoindent = true
vim.opt.smartindent = false
vim.opt.cindent = false

vim.g.copilot_debug = 1

