-- Single definition of which-key. It used to be duplicated in
-- `lua/plugins/ui.lua`, where the two `delay` values (130 vs 300) and two
-- `timeoutlen` values contradicted each other. Kept at 300 to match
-- `vim.o.timeoutlen` in `lua/config/options.lua`.
return {
	"folke/which-key.nvim",
	lazy = false,
	init = function()
		vim.o.timeoutlen = 300
		vim.o.ttimeoutlen = 10
	end,
	opts = {
		delay = 300,
		notify = false,
		win = {
			height = { min = 4, max = 25 },
		},
		spec = {
			{ "<leader>gh", group = "Git Hunks" },
		},
	},
}
