return {
	"gbprod/yanky.nvim",
	lazy = false,
	dependencies = { "kkharji/sqlite.lua" },
	event = "VeryLazy",
	opts = {
		ring = {
			history_length = 100,
			storage = "shada",
			sync_with_numbered_registers = true,
			cancel_event = "update",
			ignore_registers = { "_" },
			update_register_on_cycle = false,
		},
		system_clipboard = {
			sync_with_ring = false,
		},
		highlight = {
			on_put = true,
			on_yank = true,
			timer = 200,
		},
		preserve_cursor_position = {
			enabled = true,
		},
	},
	config = function(_, opts)
		require("yanky").setup(opts)

		-- yanky has no `keys` option, so the old
		-- `opts.keys = { { "p", false }, { "P", false } }` was silently
		-- ignored and the LazyVim yanky extra kept `p`/`P` bound to
		-- `<Plug>(YankyPutAfter)` / `<Plug>(YankyPutBefore)`.
		-- Remove them so the built-in paste is used again.
		local function unmap_put()
			for _, mode in ipairs({ "n", "x" }) do
				pcall(vim.keymap.del, mode, "p")
				pcall(vim.keymap.del, mode, "P")
			end
		end

		unmap_put()
		-- The extra's `keys` are installed by lazy.nvim when the plugin is
		-- loaded, so make sure they are gone afterwards as well.
		vim.schedule(unmap_put)
	end,
}
