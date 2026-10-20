return {
	"f-person/git-blame.nvim",
	event = "VeryLazy",
	init = function()
		vim.g.gitblame_highlight_group = "GitBlame"
	end,
	opts = {
		enabled = true,
		date_format = "%r",
		message_template = " <author> • <date> • <summary>",
		-- Draw the blame text on top of the line background instead of
		-- painting it with the default (Normal) background.
		set_extmark_options = { hl_mode = "combine" },
		-- Keep using the "GitBlame" group below, even if `init` is removed.
		highlight_group = "GitBlame",
	},
	config = function(_, opts)
		vim.api.nvim_set_hl(0, "GitBlame", {
			fg = "#8087a2",
			bg = "NONE",
			italic = true,
		})
		require("gitblame").setup(opts)
	end,
	keys = {
		{ "<leader>gb", "<cmd>GitBlameToggle<cr>", desc = "Toggle git blame" },
		{ "<leader>gB", "<cmd>GitBlameOpenCommitURL<cr>", desc = "Open commit URL" },
		{ "<leader>gs", "<cmd>GitBlameCopySHA<cr>", desc = "Copy commit SHA" },
	},
}
