return {
	"xiyaowong/transparent.nvim",
	lazy = false,
	config = function()
		require("transparent").setup({
			extra_groups = {
				"GitBlame",
			},
		})
		require("transparent").clear_prefix("GitBlame")
	end,
	keys = {
		{ "<leader>ut", "<cmd>TransparentToggle<cr>", desc = "Toggle transparency" },
	},
}
