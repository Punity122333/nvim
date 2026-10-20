return {
	"folke/trouble.nvim",
	lazy = false,
	cmd = { "Trouble" },
	opts = {
		-- `actions` is not a trouble config key, so the old `opts.actions.jump`
		-- override never ran. It also required `trouble.view.actions`, which
		-- does not exist, and called `view:current()`, which is not a method
		-- of `trouble.View`. The real actions live in
		-- `trouble.config.actions` and are called as `action(view, ctx)`,
		-- so the override is installed in `config` below.
	},
	config = function(_, opts)
		require("trouble").setup(opts)

		local actions = require("trouble.config.actions")
		local orig_jump = actions.jump

		actions.jump = function(view, ctx)
			local item = ctx and ctx.item
			if item and item.buf and item.lnum then
				local line_count = vim.api.nvim_buf_line_count(item.buf)

				if item.lnum > line_count then
					local padding = {}
					for _ = 1, (item.lnum - line_count) do
						padding[#padding + 1] = ""
					end
					vim.api.nvim_buf_set_lines(item.buf, line_count, line_count, false, padding)
				end
			end

			return orig_jump(view, ctx)
		end
	end,
	keys = {
		{ "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", desc = "Diagnostics (Trouble)" },
		{ "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", desc = "Buffer Diagnostics (Trouble)" },
	},
}
