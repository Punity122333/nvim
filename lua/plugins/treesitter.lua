-- Tree-sitter setup.
--
-- The current `nvim-treesitter` (the rewritten `main` branch) has a
-- different API than the old one:
--   * `opts.ensure_installed`  - the parsers that get installed.
--   * `opts.highlight.disable` - a *list of languages*, not a function.
--   * `opts.indent.enable` / `opts.folds.enable` - the features to turn on.
-- The options below are merged into LazyVim's own tree-sitter options (see
-- `opts = function(_, opts)`), so LazyVim's defaults - and the ones the
-- enabled extras add - are kept.  The old options that no longer exist
-- (`sync_install`, `auto_install`, `incremental_selection`,
-- `additional_vim_regex_highlighting`) are gone.
--
-- NOTE: this spec deliberately does NOT define a `config` function: a user
-- `config` replaces LazyVim's, and LazyVim's is what installs the missing
-- parsers and registers the `FileType` autocmd that starts the highlighter.
local treesitter = require("config.treesitter")

-- Parsers that LazyVim's defaults (and the enabled extras) do not ask for.
-- Everything else - bash, c, diff, json, lua, markdown, python, toml,
-- yaml, ... - comes from LazyVim itself.
local EXTRA_PARSERS = {
	"css",
	"glsl",
	"hlsl",
	"wgsl",
}

--- Add the values that are not in `list` yet.
---@param list string[]
---@param extra string[]
---@return string[]
local function extend(list, extra)
	local ret = vim.deepcopy(list or {})
	for _, value in ipairs(extra) do
		if not vim.tbl_contains(ret, value) then
			ret[#ret + 1] = value
		end
	end
	return ret
end

return {
	{
		"nvim-treesitter/nvim-treesitter",
		lazy = false,
		opts = function(_, opts)
			-- The parsers are installed into `stdpath("data")/site`.  Passing
			-- `install_dir` makes nvim-treesitter put that directory on the
			-- runtimepath itself, so the parsers and their queries are found
			-- without any manual `rtp` juggling.
			opts.install_dir = opts.install_dir or vim.fs.joinpath(vim.fn.stdpath("data"), "site")

			-- Keep every parser LazyVim (and the enabled extras) ask for and
			-- add the ones this config needs on top.
			opts.ensure_installed = extend(opts.ensure_installed, EXTRA_PARSERS)

			-- `highlight.disable` is a list of languages.  The entries the
			-- extras bring (e.g. "latex") are kept.
			opts.highlight = opts.highlight or {}
			opts.highlight.enable = true
			opts.highlight.disable = extend(opts.highlight.disable, treesitter.disable_langs)

			opts.indent = opts.indent or {}
			opts.indent.enable = true

			opts.folds = opts.folds or {}
			opts.folds.enable = true

			return opts
		end,
	},
	{ "nvim-treesitter/nvim-treesitter-textobjects", enabled = true, lazy = false },
}
