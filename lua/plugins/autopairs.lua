return {
	{ "nvim-mini/mini.pairs", enabled = false },
	{
		"windwp/nvim-autopairs",
		lazy = false,
		opts = {
			check_ts = true,
			enable_check_bracket_line = true,
			ts_config = {
				lua = { "string" },
				python = { "string" },
			},
			map_cr = true,
			map_bs = true,
		},
		config = function(_, opts)
			local autopairs = require("nvim-autopairs")
			autopairs.setup(opts)

			autopairs.add_rules(require("nvim-autopairs.rules.endwise-lua"))

			_G.smart_autopairs_cr = function()
				return autopairs.autopairs_cr()
			end

			local map_opts = { expr = true, noremap = true, silent = true }

			vim.keymap.set("i", "<S-CR>", "v:lua.smart_autopairs_cr()", map_opts)
		end,
	},
}
