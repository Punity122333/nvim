return {
	"ThePrimeagen/refactoring.nvim",

	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-treesitter/nvim-treesitter",
		"lewis6991/async.nvim",
	},

	opts = {
		prompt_func_return_type = {
			go = true,
			java = true,
			cpp = true,
			c = true,
			python = true,
			javascript = true,
			typescript = true,
			typescriptreact = true,
			lua = true,
		},

		prompt_func_param_type = {
			go = true,
			java = true,
			cpp = true,
			c = true,
			python = true,
			javascript = true,
			typescript = true,
			typescriptreact = true,
			lua = true,
		},
	},

	keys = {
		{
			"<leader>;e",
			function()
				return require("refactoring").extract_func()
			end,
			mode = { "n", "x" },
			expr = true,
			desc = "Extract Function",
		},

		{
			"<leader>;f",
			function()
				return require("refactoring").extract_func_to_file()
			end,
			mode = { "n", "x" },
			expr = true,
			desc = "Extract Function to File",
		},

		{
			"<leader>;i",
			function()
				return require("refactoring").inline_var()
			end,
			mode = { "n", "x" },
			expr = true,
			desc = "Inline Variable",
		},

		{
			"<leader>;b",
			function()
				return require("refactoring").extract_block()
			end,
			mode = "n",
			expr = true,
			desc = "Extract Block",
		},

		{
			"<leader>;bf",
			function()
				return require("refactoring").extract_block_to_file()
			end,
			mode = "n",
			expr = true,
			desc = "Extract Block to File",
		},
	},
}
