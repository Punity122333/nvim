return {
	{
		-- NOTE: this used to be written as "snacks.nvim" (no owner). It
		-- resolved to the same plugin only because another spec supplied
		-- the URL.
		"folke/snacks.nvim",
		opts = {
			scroll = { enabled = false },
		},
	},

	{
		"nvim-mini/mini.animate",
		enabled = false,
	},
}
