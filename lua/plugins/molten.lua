return {
	{
		"benlubas/molten-nvim",
		version = "^1.0.0",
		lazy = false,
		build = ":UpdateRemotePlugins",

		init = function()
			vim.g.molten_image_provider = "none"
			vim.g.molten_output_win_max_height = 20
		end,

		keys = {
			{ "<leader>;mi", "<cmd>MoltenInit python3<CR>", desc = "Molten Init Python" },
			{ "<leader>;me", "<cmd>MoltenEvaluateOperator<CR>", desc = "Molten Eval Operator", mode = "n" },
			{ "<leader>;me", "<cmd>MoltenEvaluateVisual<CR>", desc = "Molten Eval Selection", mode = "v" },
			{ "<leader>;rl", "<cmd>MoltenEvaluateLine<CR>", desc = "Molten Run Line" },
			{ "<leader>;rd", "<cmd>MoltenDelete<CR>", desc = "Molten Delete Cell" },
		},
	},
}
