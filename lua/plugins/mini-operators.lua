return {
	{
		"nvim-mini/mini.nvim",
    lazy = false,
		opts = {
			operators = {
				evaluate = {
					prefix = "gz=",
					func = function(content)
						local expr = table.concat(content.lines, "\n")
						-- the second return value of `load` is the syntax
						-- error, which is not needed here
						local f = load("return " .. expr)
						if f then
							local ok, res = pcall(f)
							if ok then
								return vim.split(tostring(res), "\n")
							end
						end
						return content.lines
					end,
				},
				exchange = { prefix = "gzx" },
				multiply = { prefix = "gzm" },
				replace = { prefix = "gzr" },
				-- `sort` used to share the "gzr" prefix with `replace`.
				-- mini.operators maps `prefix` and `prefix .. <last char>`,
				-- so both operators produced the exact same mappings and
				-- `sort` (mapped last) overwrote `replace` entirely.
				sort = { prefix = "gzs" },
			},
		},
		config = function(_, opts)
			require("mini.operators").setup(opts.operators)
		end,
	},
}
