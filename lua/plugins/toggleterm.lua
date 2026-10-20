return {
	"akinsho/toggleterm.nvim",
  lazy = false,
	version = "*",
	config = function()
		require("toggleterm").setup({
			size = 20,
			-- The old value was `[[<c-s-\>]]`, which termcodes to
			-- <Esc><C-S><C-\> instead of <C-\>.
			open_mapping = [[<c-\>]],
			shade_terminals = false,
			close_on_exit = true,
			direction = "float",
			float_opts = {
				border = "rounded",
				winblend = 0,
			},
			highlights = {
				Normal = { guibg = "#1a1b26" },
				FloatBorder = { guifg = "#27a1b9", guibg = "#1a1b26" },
			},
			-- NOTE: there is no `on_exit` handler any more. The old one
			-- called `t:close()` while `close_on_exit = true` was already
			-- closing the terminal, so `on_close` ran twice.
		})
	end,
}
