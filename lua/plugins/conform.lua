local INDENT_WIDTH = require("config.indent_width").width
local COLUMN_WIDTH = tostring(require("config.indent_width").column_width)

-- Formatters never read 'shiftwidth', so they need telling explicitly.
-- LLVM's defaults (ContinuationIndentWidth 4, ColumnLimit 80) split
-- `if (c) stmt;` across two lines and indent the continuation by 4, which
-- made expanded snippets look mis-indented right after `<leader>fm`.
local CLANG_STYLE = table.concat({
	"{BasedOnStyle: LLVM",
	"IndentWidth: " .. INDENT_WIDTH,
	"ContinuationIndentWidth: " .. INDENT_WIDTH,
	"ColumnLimit: 0",
	"AllowShortIfStatementsOnASingleLine: true",
	"AllowShortLoopsOnASingleLine: true",
	"AllowShortBlocksOnASingleLine: true",
	"AllowShortFunctionsOnASingleLine: Inline",
	"AllowShortCaseLabelsOnASingleLine: true",
	"InsertBraces: false}",
}, ", ")

---Formatters never read 'shiftwidth', so they need telling explicitly --
---otherwise `<leader>fm` re-indents freshly expanded snippets.
---
---Each override below is applied *only* when the buffer's project supplies no
---formatter config of its own, so real projects keep winning. (clang-format's
---`--fallback-style` can't carry these settings; it only accepts style names.)
local function without_project_config(bufnr, markers)
	local name = vim.api.nvim_buf_get_name(bufnr)
	if name == "" then
		return true
	end
	for _, marker in ipairs(markers) do
		if vim.fs.root(name, marker) then
			return false
		end
	end
	return true
end

local function clang_format(bufnr)
	if not without_project_config(bufnr, { ".clang-format" }) then
		return {}
	end
	return { prepend_args = { "--style", CLANG_STYLE } }
end

local function prettier(bufnr)
	if
		not without_project_config(bufnr, {
			".prettierrc",
			".prettierrc.json",
			".prettierrc.yml",
			".prettierrc.yaml",
			".prettierrc.toml",
			".prettierrc.json5",
			"prettier.config.js",
			"prettier.config.mjs",
			"prettier.config.cjs",
			".editorconfig",
		})
	then
		return {}
	end
	return {
		prepend_args = {
			"--tab-width",
			tostring(INDENT_WIDTH),
			"--use-tabs",
			"false",
			"--print-width",
			COLUMN_WIDTH,
		},
	}
end

local function stylua(bufnr)
	if not without_project_config(bufnr, { "stylua.toml", ".stylua.toml", ".editorconfig" }) then
		return {}
	end
	return {
		prepend_args = {
			"--indent-type",
			"Spaces",
			"--indent-width",
			tostring(INDENT_WIDTH),
			"--column-width",
			COLUMN_WIDTH,
		},
	}
end

local function rustfmt(bufnr)
	if not without_project_config(bufnr, { "rustfmt.toml", ".rustfmt.toml" }) then
		return {}
	end
	return {
		prepend_args = {
			"--config",
			"hard_tabs=false,tab_spaces=" .. INDENT_WIDTH,
		},
	}
end

return {
	"stevearc/conform.nvim",
	cmd = { "ConformInfo" },
	opts = {
		formatters = {
			["clang-format"] = clang_format,
			prettier = prettier,
			stylua = stylua,
			rustfmt = rustfmt,
		},
		formatters_by_ft = {
			lua = { "stylua" },
			cpp = { "clang-format" },
			c = { "clang-format" },
			python = { "ruff_format" },
			javascript = { "prettier" },
			typescript = { "prettier" },
			typescriptreact = { "prettier" },
			javascriptreact = { "prettier" },
			angular = { "prettier" },
			css = { "prettier" },
			scss = { "prettier" },
			html = { "prettier" },
			jsonc = { "prettier" },
			graphql = { "prettier" },
			go = { "gofmt" },
			haskell = { "ormolu" },
			java = { "google-java-format" },
			json = { "prettier" },
			kotlin = { "ktlint" },
			markdown = { "prettier" },
			php = { "php-cs-fixer" },
			r = { "styler" },
			ruby = { "rubocop" },
			rust = { "rustfmt" },
			sql = { "sql-formatter" },
			svelte = { "prettier" },
			tailwind = { "prettier" },
			tex = { "latexindent" },
			toml = { "taplo" },
			yaml = { "yamlfmt" },
		},
		format_on_save = false,
	},
}
