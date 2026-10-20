return {
	"folke/lazydev.nvim",
	ft = "lua",
	cmd = "LazyDev",
	opts = {
		library = {
		  -- NOTE: the "${3rd}" placeholders are not expanded by lazydev
		  -- (it only ever appears in the README), so those three entries
		  -- pointed at literal, non-existent directories.
		  "LazyVim",
		},
		enabled = function(root_dir)
			return vim.g.lazydev_enabled ~= false
		end,
	},
}
