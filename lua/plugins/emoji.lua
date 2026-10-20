return {
	"allaman/emoji.nvim",
	-- The cmp source is registered from `setup()`, and the blink `emoji`
	-- provider needs it in *every* filetype. With `ft = { "markdown",
	-- "text" }` the source only existed in those two filetypes, so the
	-- blink provider was dead everywhere else.
	lazy = false,
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-telescope/telescope.nvim",
		-- blink.compat ships a `cmp` shim whose `register_source` feeds
		-- blink.compat's registry (the one blink's compat source reads).
		-- The real nvim-cmp registers into *its* registry, which blink
		-- cannot see, so nvim-cmp is not needed (and not installed).
		"saghen/blink.compat",
	},
	opts = {
		enable_cmp_integration = true,
	},
	config = function(_, opts)
		require("emoji").setup(opts)

		local has_telescope, telescope = pcall(require, "telescope")
		if has_telescope then
			telescope.load_extension("emoji")
			vim.keymap.set("n", "<leader>se", telescope.extensions.emoji.emoji, { desc = "Search Emojis" })
		end
	end,
}
