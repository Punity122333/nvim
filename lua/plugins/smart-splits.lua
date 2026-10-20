-- Direction aware window navigation and resizing:
-- https://github.com/smart-splits-nvim/smart-splits.nvim
--
-- Resize with a mental model of left/right/up/down instead of
-- wider/narrower/taller/shorter, and move the cursor between splits
-- without the usual `<C-w>` prefix.
--
-- The plugin sets no mappings of its own, so they are defined here.
return {
	"smart-splits-nvim/smart-splits.nvim",
	version = "^3.0.0",
	dependencies = {
		-- kitty is the terminal in use, so the kitty backend makes the
		-- navigation cross the terminal multiplexer panes as well.
		-- NOTE: it needs `allow_remote_control yes` in kitty.conf; without
		-- it the backend is simply not detected and only the in-editor
		-- resizing works.
		{ "smart-splits-nvim/backend-kitty", main = "smart-splits-backend-kitty" },
	},
	opts = {
		mux = {
			backend = "smart-splits-backend-kitty",
			-- don't warn about the backend not being usable
			warn_if_unusable = false,
		},
	},
	keys = {
		-- resize the current split
		{
			"<A-h>",
			function()
				require("smart-splits").resize_left()
			end,
			desc = "Resize left",
		},
		{
			"<A-j>",
			function()
				require("smart-splits").resize_down()
			end,
			desc = "Resize down",
		},
		{
			"<A-k>",
			function()
				require("smart-splits").resize_up()
			end,
			desc = "Resize up",
		},
		{
			"<A-l>",
			function()
				require("smart-splits").resize_right()
			end,
			desc = "Resize right",
		},
		-- move the cursor between splits
		{
			"<C-h>",
			function()
				require("smart-splits").move_cursor_left()
			end,
			desc = "Move cursor left",
		},
		{
			"<C-j>",
			function()
				require("smart-splits").move_cursor_down()
			end,
			desc = "Move cursor down",
		},
		{
			"<C-k>",
			function()
				require("smart-splits").move_cursor_up()
			end,
			desc = "Move cursor up",
		},
		{
			"<C-l>",
			function()
				require("smart-splits").move_cursor_right()
			end,
			desc = "Move cursor right",
		},
		-- swap the buffer with the neighbouring window
		{
			"<leader><leader>h",
			function()
				require("smart-splits").swap_buf_left()
			end,
			desc = "Swap buffer left",
		},
		{
			"<leader><leader>j",
			function()
				require("smart-splits").swap_buf_down()
			end,
			desc = "Swap buffer down",
		},
		{
			"<leader><leader>k",
			function()
				require("smart-splits").swap_buf_up()
			end,
			desc = "Swap buffer up",
		},
		{
			"<leader><leader>l",
			function()
				require("smart-splits").swap_buf_right()
			end,
			desc = "Swap buffer right",
		},
	},
}
