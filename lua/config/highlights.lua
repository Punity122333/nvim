-- lua/config/highlights.lua
--
-- Single owner of the palette and of every custom highlight.
--
-- `apply()` is called once when this module is loaded and again from the
-- `ThemeGodMode` augroup in init.lua (see `apply_theme`): a colorscheme
-- resets every highlight it owns, so the custom ones have to be re-applied
-- whenever the colorscheme changes.
--
-- init.lua only owns the generic re-tint loop and the few groups that
-- override it; anything set here must not be set there as well.
---@diagnostic disable: undefined-global
local M = {}

-- ── palette ──────────────────────────────────────────────────────────────────
local COLOR_BACKGROUND_PRIMARY = "#1a1b26"
local COLOR_BACKGROUND_SECONDARY = "#111116"
local COLOR_FOREGROUND_PRIMARY = "#cdd6f4"
local COLOR_FOREGROUND_SECONDARY = "#bac2de"
local COLOR_FOREGROUND_ACCENT = "#111116"
local COLOR_FOREGROUND_SUBTLE = "#232330"
local COLOR_SELECTION_BLUE = "#28344a"
local COLOR_SNACKS_PICKER_SELECTED = "#88c0d0"
local COLOR_BORDER = "#27a1b9"
local COLOR_MASON_HIGHLIGHT = "#e0af68"
local COLOR_MASON_MUTED = "#27a1b9"
local COLOR_LSP_TYPE_VARIABLE = "#9CDCFE"
local COLOR_LSP_TYPE_MACRO_CPP = "#3497E7"
local COLOR_GENERAL_NONE = "NONE"
local COLOR_STATUS_LINE = "#16161e"
local COLOR_CURSOR_FG = "#000000"
local COLOR_CURSOR_BG = "#00ff00"
local COLOR_FG_MARKDOWN_BOLD = "#ff9e64"
local COLOR_UNUSED_DIAGNOSTIC = "#6c7086"
local COLOR_DAP_UNAVAILABLE = "#565f89"
local GUICURSOR_DEFAULT = "n-v-c-sm:block-Cursor,i-ci-ve:ver25-Cursor,r-cr-o:hor20-Cursor"

--- Shared palette, used by init.lua so that a colour is defined exactly once.
M.colors = {
	background_primary = COLOR_BACKGROUND_PRIMARY,
	background_secondary = COLOR_BACKGROUND_SECONDARY,
	foreground_primary = COLOR_FOREGROUND_PRIMARY,
	foreground_secondary = COLOR_FOREGROUND_SECONDARY,
	foreground_accent = COLOR_FOREGROUND_ACCENT,
	foreground_subtle = COLOR_FOREGROUND_SUBTLE,
	selection_blue = COLOR_SELECTION_BLUE,
	status_line = COLOR_STATUS_LINE,
	border = COLOR_BORDER,
	cursor_fg = COLOR_CURSOR_FG,
	cursor_bg = COLOR_CURSOR_BG,
	markdown_bold = COLOR_FG_MARKDOWN_BOLD,
	unused_diagnostic = COLOR_UNUSED_DIAGNOSTIC,
}

--- Groups that init.lua used to set itself (and therefore had to set again
--- after every colorscheme change).  They live here now, so that a group is
--- defined in exactly one place.
function M.apply_overrides()
	vim.api.nvim_set_hl(0, "@markup.strong", { fg = COLOR_FG_MARKDOWN_BOLD, bold = true, force = true })
	vim.api.nvim_set_hl(0, "RenderMarkdownCode", { bg = COLOR_BACKGROUND_PRIMARY, blend = 0, force = true })
	vim.api.nvim_set_hl(0, "LspReferenceRead", { bg = COLOR_GENERAL_NONE, force = true })
	vim.api.nvim_set_hl(0, "BlinkCmpSignatureHelpBorder", { fg = COLOR_BORDER, bg = COLOR_BACKGROUND_PRIMARY, force = true })
	vim.api.nvim_set_hl(0, "BlinkCmpSignatureHelp", { bg = COLOR_BACKGROUND_PRIMARY, force = true })
	vim.api.nvim_set_hl(0, "BlinkCmpSignatureActiveParameter", { bg = COLOR_BACKGROUND_PRIMARY, force = true })
	vim.api.nvim_set_hl(0, "StatusLine", { bg = COLOR_STATUS_LINE, force = true })
	vim.api.nvim_set_hl(0, "StatusLineNC", { bg = COLOR_STATUS_LINE, force = true })

	-- The "Selected" variants of the bufferline groups.  bufferline derives
	-- them from the groups above (and adds `bold`), but it also sets them
	-- itself, so they are spelled out here: that way the result does not
	-- depend on which of the two runs last.
	vim.api.nvim_set_hl(0, "BufferLineErrorSelected", { fg = "#f9a0aa", bg = COLOR_BACKGROUND_PRIMARY, bold = true, force = true })
	vim.api.nvim_set_hl(0, "BufferLineErrorDiagnosticSelected", { fg = "#f9a0aa", bg = COLOR_BACKGROUND_PRIMARY, bold = true, force = true })
	vim.api.nvim_set_hl(0, "BufferLineWarningSelected", { fg = "#e0af68", bg = COLOR_BACKGROUND_PRIMARY, bold = true, force = true })
	vim.api.nvim_set_hl(0, "BufferLineWarningDiagnosticSelected", { fg = "#e0af68", bg = COLOR_BACKGROUND_PRIMARY, bold = true, force = true })
	vim.api.nvim_set_hl(0, "BufferLineInfoSelected", { fg = "#7dcfff", bg = COLOR_BACKGROUND_PRIMARY, bold = true, force = true })
	vim.api.nvim_set_hl(0, "BufferLineInfoDiagnosticSelected", { fg = "#7dcfff", bg = COLOR_BACKGROUND_PRIMARY, bold = true, force = true })
	vim.api.nvim_set_hl(0, "BufferLineHintSelected", { fg = "#1abc9c", bg = COLOR_BACKGROUND_PRIMARY, bold = true, force = true })
	vim.api.nvim_set_hl(0, "BufferLineHintDiagnosticSelected", { fg = "#1abc9c", bg = COLOR_BACKGROUND_PRIMARY, bold = true, force = true })
	vim.api.nvim_set_hl(0, "BufferLineModifiedSelected", { fg = COLOR_FG_MARKDOWN_BOLD, bg = COLOR_BACKGROUND_PRIMARY, bold = true, blend = 0, force = true })
end

function M.apply()
	vim.api.nvim_set_hl(0, "markdownBold", { bold = true, force = true })
	vim.api.nvim_set_hl(0, "@text.strong", { bold = true, force = true })

	local sel_groups = { "BlinkCmpMenuSelection", "PmenuSel", "CmpItemAbbrSelected", "TelescopeSelection" }
	for _, g in ipairs(sel_groups) do
		vim.api.nvim_set_hl(0, g, { bg = COLOR_SELECTION_BLUE, force = true })
	end

	local float_groups = { "NormalFloat", "FloatTitle", "MsgArea" }
	for _, g in ipairs(float_groups) do
		vim.api.nvim_set_hl(0, g, { bg = COLOR_BACKGROUND_PRIMARY, force = true })
	end

	local blink = {
		"BlinkCmpDocSeparator",
		"NoiceLspSignatureHelp",
	}
	for _, g in ipairs(blink) do
		vim.api.nvim_set_hl(0, g, { bg = COLOR_BACKGROUND_SECONDARY, blend = 0, force = true })
	end
	vim.api.nvim_set_hl(0, "NoicePopupBorder", { bg = COLOR_GENERAL_NONE, fg = COLOR_BORDER, blend = 0, force = true })
	vim.api.nvim_set_hl(
		0,
		"NoicePopupBorderSearch",
		{ bg = COLOR_GENERAL_NONE, fg = COLOR_BORDER, blend = 0, force = true }
	)
	vim.api.nvim_set_hl(0, "NoicePopupBorderInput", { bg = COLOR_GENERAL_NONE, fg = COLOR_BORDER, blend = 0, force = true })
	vim.api.nvim_set_hl(0, "NoicePopupTitleSearch", { bg = COLOR_GENERAL_NONE, fg = COLOR_BORDER, blend = 0, force = true })
	vim.api.nvim_set_hl(0, "NoicePopupTitleInput", { bg = COLOR_GENERAL_NONE, fg = COLOR_BORDER, blend = 0, force = true })
	vim.api.nvim_set_hl(0, "LspSignatureActiveParameter", { bg = COLOR_BACKGROUND_PRIMARY, blend = 0, force = true })
	vim.api.nvim_set_hl(0, "BlinkCmpDocSeparator", { bg = COLOR_BACKGROUND_PRIMARY, blend = 0, force = true })
	vim.api.nvim_set_hl(0, "Pmenu", { bg = COLOR_BACKGROUND_PRIMARY, blend = 0, force = true })
	vim.api.nvim_set_hl(0, "NoicePopupmenuBorder", { bg = COLOR_GENERAL_NONE, fg = COLOR_BORDER, blend = 0, force = true })
	vim.api.nvim_set_hl(0, "NoicePopup", { bg = COLOR_BACKGROUND_PRIMARY, force = true })
	vim.api.nvim_set_hl(0, "GitSignsAdd", { link = "@string", force = true })
	vim.api.nvim_set_hl(0, "GitSignsCurrentLineBlame", { bg = COLOR_SELECTION_BLUE })
	vim.api.nvim_set_hl(0, "@mutable", { fg = COLOR_FG_MARKDOWN_BOLD, italic = true, bold = true })
	vim.api.nvim_set_hl(0, "@type.builtin", { link = "Type" })
	vim.api.nvim_set_hl(0, "BufferLineError", { fg = "#f9a0aa", bg = COLOR_BACKGROUND_PRIMARY, blend = 0, force = true })
	vim.api.nvim_set_hl(
		0,
		"BufferLineErrorSelected",
		{ fg = "#f9a0aa", bg = COLOR_BACKGROUND_PRIMARY, bold = true, force = true }
	)
	vim.api.nvim_set_hl(0, "BufferLineErrorDiagnostic", { fg = "#f9a0aa", bg = COLOR_BACKGROUND_PRIMARY, force = true })

	-- WARNING
	vim.api.nvim_set_hl(0, "BufferLineWarning", { fg = "#e0af68", bg = COLOR_BACKGROUND_PRIMARY, blend = 0, force = true })
	vim.api.nvim_set_hl(
		0,
		"BufferLineWarningSelected",
		{ fg = "#e0af68", bg = COLOR_BACKGROUND_PRIMARY, bold = true, force = true }
	)
	vim.api.nvim_set_hl(0, "BufferLineWarningDiagnostic", { fg = "#e0af68", bg = COLOR_BACKGROUND_PRIMARY, force = true })

	vim.api.nvim_set_hl(0, "BufferLineInfo", { fg = "#7dcfff", bg = COLOR_BACKGROUND_PRIMARY, blend = 0, force = true })
	vim.api.nvim_set_hl(
		0,
		"BufferLineInfoSelected",
		{ fg = "#7dcfff", bg = COLOR_BACKGROUND_PRIMARY, bold = true, force = true }
	)
	vim.api.nvim_set_hl(0, "BufferLineInfoDiagnostic", { fg = "#7dcfff", bg = COLOR_BACKGROUND_PRIMARY, force = true })

	vim.api.nvim_set_hl(0, "@io.cout", { fg = "#f9a0aa" })
	vim.api.nvim_set_hl(0, "@io.cin", { fg = "#f9a0aa" })
	vim.api.nvim_set_hl(0, "@io.endl", { fg = COLOR_FG_MARKDOWN_BOLD })
	-- HINT
	vim.api.nvim_set_hl(0, "BufferLineHint", { fg = "#1abc9c", bg = COLOR_BACKGROUND_PRIMARY, blend = 0, force = true })
	vim.api.nvim_set_hl(
		0,
		"BufferLineHintSelected",
		{ fg = "#1abc9c", bg = COLOR_BACKGROUND_PRIMARY, bold = true, force = true }
	)
	vim.api.nvim_set_hl(0, "BufferLineHintDiagnostic", { fg = "#1abc9c", bg = COLOR_BACKGROUND_PRIMARY, force = true })

	-- MODIFIED / CHANGES
	vim.api.nvim_set_hl(0, "BufferLineModified", { fg = COLOR_FG_MARKDOWN_BOLD, bg = COLOR_BACKGROUND_PRIMARY, force = true })

	local sep = { "Split", "Splitter", "Separator", "WinSeparator", "VertSplit" }
	for _, g in ipairs(sep) do
		vim.api.nvim_set_hl(0, g, { bg = COLOR_BACKGROUND_PRIMARY, blend = 20, fg = COLOR_FOREGROUND_ACCENT, force = true })
	end

	vim.api.nvim_set_hl(0, "AvanteSidebarWinSeparator", { fg = COLOR_FOREGROUND_ACCENT, bg = COLOR_BACKGROUND_PRIMARY })
	vim.api.nvim_set_hl(
		0,
		"AvanteSidebarWinHorizontalSeparator",
		{ fg = COLOR_FOREGROUND_ACCENT, bg = COLOR_BACKGROUND_PRIMARY }
	)

	vim.api.nvim_set_hl(0, "AvantePopup", { bg = COLOR_BACKGROUND_PRIMARY, force = true, blend = 0 })
	vim.api.nvim_set_hl(0, "AvantePopupHint", { bg = COLOR_BACKGROUND_PRIMARY, force = true, blend = 0 })

	local snack_hls = {
		SnacksPickerSelected = { bg = COLOR_GENERAL_NONE, fg = COLOR_SNACKS_PICKER_SELECTED },
		SnacksPickerCursorLine = { bg = COLOR_SELECTION_BLUE },
	}
	for group, settings in pairs(snack_hls) do
		vim.api.nvim_set_hl(0, group, settings)
	end
	vim.api.nvim_set_hl(0, "AvantePromptInput", { bg = COLOR_BACKGROUND_PRIMARY, force = true, blend = 0 })

	vim.api.nvim_set_hl(
		0,
		"AvantePromptInputBorder",
		{ bg = COLOR_BACKGROUND_PRIMARY, fg = COLOR_BORDER, force = true, blend = 0 }
	)

	vim.api.nvim_set_hl(0, "@keyword.repeat", { link = "@keyword" })
	vim.api.nvim_set_hl(0, "@keyword.conditional", { link = "@keyword" })
	vim.api.nvim_set_hl(0, "@bracket.square", { fg = "#7aa2f7" })
	vim.api.nvim_set_hl(0, "@bracket.paren", { fg = "#f38ba8" })
	vim.api.nvim_set_hl(0, "@bracket.curly", { fg = "#fab387" })
	vim.api.nvim_set_hl(0, "DapUIPlayPause", { fg = "#7dcfff", bg = COLOR_BACKGROUND_PRIMARY })
	vim.api.nvim_set_hl(0, "DapUIStepOver", { fg = "#7dcfff", bg = COLOR_BACKGROUND_PRIMARY })
	vim.api.nvim_set_hl(0, "DapUIStepInto", { fg = "#7dcfff", bg = COLOR_BACKGROUND_PRIMARY })
	vim.api.nvim_set_hl(0, "DapUIStepOut", { fg = "#7dcfff", bg = COLOR_BACKGROUND_PRIMARY })
	vim.api.nvim_set_hl(0, "DapUIRestart", { fg = COLOR_FG_MARKDOWN_BOLD, bg = COLOR_BACKGROUND_PRIMARY })
	vim.api.nvim_set_hl(0, "DapUIStop", { fg = "#f9a0aa", bg = COLOR_BACKGROUND_PRIMARY })
	vim.api.nvim_set_hl(0, "@variable.builtin", { fg = "#f9a0aa", bold = false, italic = false })
	vim.api.nvim_set_hl(0, "DapUIUnavailable", { fg = COLOR_DAP_UNAVAILABLE, bg = COLOR_BACKGROUND_PRIMARY })
	vim.api.nvim_set_hl(0, "DapUIControls", { bg = COLOR_BACKGROUND_PRIMARY })
	vim.api.nvim_set_hl(0, "DapUIControlsButton", { bg = COLOR_BACKGROUND_PRIMARY })
	vim.api.nvim_set_hl(0, "DapUIControlsDisabled", { bg = COLOR_BACKGROUND_PRIMARY })
	vim.api.nvim_set_hl(0, "DapUIFloatNormal", { bg = COLOR_BACKGROUND_PRIMARY })
	vim.api.nvim_set_hl(0, "BlinkCmpMenu", { bg = COLOR_BACKGROUND_PRIMARY, force = true })
	vim.api.nvim_set_hl(0, "MasonHeader", { bg = COLOR_BACKGROUND_PRIMARY, force = true })
	vim.api.nvim_set_hl(0, "MasonHeaderSecondary", { bg = COLOR_BACKGROUND_PRIMARY, force = true })
	vim.api.nvim_set_hl(0, "MasonHighlightBlockBold", { fg = COLOR_MASON_HIGHLIGHT, force = true })
	vim.api.nvim_set_hl(0, "MasonMutedBlock", { fg = COLOR_MASON_MUTED, force = true })
	vim.api.nvim_set_hl(0, "BlinkCmpDoc", { bg = COLOR_BACKGROUND_PRIMARY, force = true })
	vim.api.nvim_set_hl(0, "BlinkCmpDocBorder", { fg = COLOR_BORDER, bg = COLOR_BACKGROUND_PRIMARY, force = true })
	vim.api.nvim_set_hl(0, "@square_bracket", { fg = "#3d59a1", bold = true, force = true })
	vim.api.nvim_set_hl(0, "@module.python", { link = "@type.python" })
	vim.api.nvim_set_hl(0, "@keyword.import.python", { link = "@keyword.conditional.python" })
	vim.api.nvim_set_hl(0, "@keyword.import.rust", { link = "@keyword.conditional.python" })
	vim.api.nvim_set_hl(0, "@lsp.type.namespace.python", { link = "@module.python" })
	vim.api.nvim_set_hl(0, "@lsp.type.variable", { fg = COLOR_LSP_TYPE_VARIABLE })
	vim.api.nvim_set_hl(0, "@variable", { fg = COLOR_LSP_TYPE_VARIABLE })
	vim.api.nvim_set_hl(0, "@lsp.type.macro.cpp", { fg = COLOR_LSP_TYPE_MACRO_CPP })
	vim.api.nvim_set_hl(0, "GrugFarResultsMatch", { link = "@type.builtin.cpp" })
	vim.api.nvim_set_hl(0, "ToggleTerm1FloatBorder", { bg = COLOR_BACKGROUND_PRIMARY, fg = COLOR_BORDER, force = true })
	vim.api.nvim_set_hl(0, "ToggleTerm2FloatBorder", { bg = COLOR_BACKGROUND_PRIMARY, fg = COLOR_BORDER, force = true })
	vim.api.nvim_set_hl(0, "PmenuKind", { bg = COLOR_GENERAL_NONE, force = true })
	vim.api.nvim_set_hl(0, "LspInfoBorder", { bg = COLOR_BACKGROUND_PRIMARY, force = true })
	vim.api.nvim_set_hl(0, "@conceal", { bg = COLOR_BACKGROUND_PRIMARY, force = true })
	vim.api.nvim_set_hl(0, "RenderMarkdownCodeInline", { bg = COLOR_BACKGROUND_PRIMARY, force = true })
	vim.api.nvim_set_hl(0, "BufferLineBuffer", { bg = COLOR_BACKGROUND_PRIMARY, force = true })
	vim.api.nvim_set_hl(0, "Substitute", { link = "SubstituteRange" })
	vim.api.nvim_set_hl(0, "@punctuation.bracket", { fg = COLOR_FG_MARKDOWN_BOLD })
	vim.api.nvim_set_hl(0, "@operator", { link = "Constant" })
	vim.cmd.highlight("MyTerminalBorder guifg=" .. COLOR_BACKGROUND_PRIMARY)

	vim.opt.guicursor = GUICURSOR_DEFAULT

	local hl = vim.api.nvim_get_hl(0, { name = "@keyword" })
	hl.bold = true
	---@diagnostic disable-next-line: param-type-mismatch
	vim.api.nvim_set_hl(0, "@keyword", hl)

	local hl2 = vim.api.nvim_get_hl(0, { name = "Comment" })
	hl2.italic = true
	hl2.bold = false
	---@diagnostic disable-next-line: param-type-mismatch
	vim.api.nvim_set_hl(0, "Comment", hl2)
	vim.api.nvim_set_hl(0, "@module.haskell", { link = "@type.haskell" })

	local hl = vim.api.nvim_get_hl(0, { name = "@constructor.python", link = false })
	hl.bold = true
	vim.api.nvim_set_hl(0, "@constructor.python", hl)

	M.apply_overrides()
end

M.apply()

return M
