-- lua/config/treesitter.lua
--
-- Single owner of the rules that decide where the tree-sitter highlighter
-- is *not* started.
--
-- The current `nvim-treesitter` (the rewritten `main` branch) only knows
-- `opts.highlight.disable`, and that option is a *list of languages* - the
-- old `disable = function(lang, buf)` is gone.  The rules that depend on
-- the buffer itself (its size, whether it is a diff, ...) cannot be
-- expressed that way, so they are applied one level lower: the
-- `vim.treesitter.start` wrapper in `init.lua` asks `M.disabled()` before
-- it starts the highlighter.
--
-- The two mechanisms are deliberately kept in sync: `M.disable_langs` is
-- handed to LazyVim's tree-sitter options (see `lua/plugins/treesitter.lua`)
-- and `M.disabled()` implements the same list plus the buffer rules.
local M = {}

--- Languages for which the highlighter is never started.
---
--- `help` is not in the list because Neovim maps that filetype to the
--- `vimdoc` language, and `markdown_inline` is the parser that is injected
--- into markdown.
M.disable_langs = {
	"diff",
	"gitcommit",
	"markdown",
	"markdown_inline",
	"vimdoc",
}

--- Filetypes that never get tree-sitter highlighting.
---
--- Most of them have no parser at all, so this list is mostly
--- documentation - but it also keeps the `snacks_*` buffers, which have
--- their own syntax files, from being touched.
local DISABLED_FILETYPES = {
	"alpha",
	"avante",
	"avante-input",
	"dashboard",
	"gitcommit",
	"help",
	"markdown",
	"oil",
	"TelescopePrompt",
	"NvimTree",
}

--- C/C++ files with more lines than this are not highlighted: the parse is
--- slow and a file that big is not read anyway.
local MAX_C_LINES = 1000

--- Files bigger than this are not highlighted either.
local MAX_FILE_SIZE = 100 * 1024

--- Cache of the "file is too big" answer, keyed by file name.  The file
--- size of a buffer does not change while it is open, and `fs_stat` is a
--- syscall.
local too_big_cache = {}

--- Is the file behind this buffer too big to be highlighted?
---@param buf integer
---@return boolean
local function too_big(buf)
	local name = vim.api.nvim_buf_get_name(buf)
	if name == "" then
		return false
	end

	local cached = too_big_cache[name]
	if cached ~= nil then
		return cached
	end

	local ok, stat = pcall(vim.uv.fs_stat, name)
	local big = ok and stat ~= nil and stat.size > MAX_FILE_SIZE
	too_big_cache[name] = big
	return big
end

--- Is the buffer shown as a diff?
---
--- 'diff' is a *window* option, so every window that shows the buffer has
--- to be looked at.
---@param buf integer
---@return boolean
local function in_diff(buf)
	for _, win in ipairs(vim.api.nvim_list_wins()) do
		if vim.api.nvim_win_get_buf(win) == buf and vim.wo[win].diff then
			return true
		end
	end
	return false
end

--- Should the highlighter be skipped for this buffer?
---@param buf? integer
---@param lang? string the tree-sitter language, if it is already known
---@return boolean
function M.disabled(buf, lang)
	buf = buf or vim.api.nvim_get_current_buf()
	local ft = vim.bo[buf].filetype

	if vim.tbl_contains(DISABLED_FILETYPES, ft) then
		return true
	end

	if in_diff(buf) then
		return true
	end

	lang = lang or vim.treesitter.language.get_lang(ft)
	if lang and vim.tbl_contains(M.disable_langs, lang) then
		return true
	end

	if (lang == "c" or lang == "cpp") and vim.api.nvim_buf_line_count(buf) > MAX_C_LINES then
		return true
	end

	return too_big(buf)
end

return M
