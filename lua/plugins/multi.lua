return {
	{
		"jake-stewart/multicursor.nvim",
		branch = "main",
		enabled = true,
		-- Every mapping lives inside `config`, so without an explicit
		-- trigger the plugin would never be loaded and all of them would
		-- be dead.
		lazy = false,
		config = function()
			local mc = require("multicursor-nvim")

			mc.setup({
				updatetime = 150,
			})

			local function clear_all()
				if mc.hasCursors() then
					mc.clearCursors()
					vim.cmd("redraw!")
					vim.cmd("nohlsearch")
				else
					vim.cmd("nohlsearch")
				end
			end

			local function toggleCursorState()
				if mc.cursorsEnabled() then
					mc.toggleCursor()
					mc.disableCursors()
				else
					mc.toggleCursor()
					mc.enableCursors()
				end
			end

			local set = vim.keymap.set

			set({ "n", "v" }, "L", function()
				if not mc.hasCursors() then
					vim.cmd("normal! n")
				else
					mc.nextCursor()
				end
			end, { desc = "Next cursor/search" })

			set({ "n", "v" }, "H", function()
				if not mc.hasCursors() then
					vim.cmd("normal! N")
				else
					mc.prevCursor()
				end
			end, { desc = "Prev cursor/search" })

			set({ "n", "x" }, "n", "<Nop>", { desc = "Disable n" })
			set({ "n", "x" }, "N", "<Nop>", { desc = "Disable N" })

			set({ "n", "v" }, "\\q", mc.toggleCursor, { desc = "Toggle cursor" })
			set({ "n", "v" }, "\\k", function()
				mc.lineAddCursor(-1)
			end, { desc = "Add cursor above" })
			set({ "n", "v" }, "\\j", function()
				mc.lineAddCursor(1)
			end, { desc = "Add cursor below" })
			set({ "n", "v" }, "\\m", function()
				mc.lineAddCursor(0)
			end, { desc = "Add cursor here" })

			set({ "n", "v" }, "\\n", function()
				mc.matchAddCursor(1)
			end, { desc = "Add cursor match" })
			set({ "n", "v" }, "\\s", function()
				mc.matchSkipCursor(1)
			end, { desc = "Skip match" })
			set({ "n", "v" }, "\\a", mc.matchAllAddCursors, { desc = "Add cursors (all)" })

			set({ "n", "v" }, "\\c", clear_all, { desc = "Clear cursors" })
			set({ "n", "v" }, "\\w", toggleCursorState, { desc = "Toggle multicursor" })
		end,
	},
	{
		"mg979/vim-visual-multi",
		enabled = false,
	},
}
