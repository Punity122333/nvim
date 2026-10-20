return {
	{
		"mistricky/codesnap.nvim",
		build = "make build_generator",
		keys = {
			{
				"<leader>cc",
				function()
					vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "x", false)
					vim.cmd("CodeSnap")
				end,
				mode = "v",
				desc = "Copy snap",
			},
			{
				"<leader>cl",
				function()
					vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "x", false)
					vim.cmd("CodeSnapSave")
				end,
				mode = "v",
				desc = "Save snap",
			},
			{
				"<leader>ca",
				function()
					vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "x", false)
					vim.cmd("CodeSnapASCII")
				end,
				mode = "v",
				desc = "Copy snap (ASCII)",
			},
			{
				"<leader>ch",
				function()
					vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "x", false)
					vim.cmd("CodeSnapHighlight")
				end,
				mode = "v",
				desc = "Copy snap (highlight)",
			},
			{
				"<leader>ch",
				function()
					vim.fn.setpos("'<", { 0, 1, 1, 0 })
					vim.fn.setpos("'>", { 0, vim.api.nvim_buf_line_count(0), 1, 0 })
					vim.cmd("CodeSnapHighlight")
				end,
				mode = "n",
				desc = "Copy snap (highlight, whole buffer)",
			},
			{
				"<leader>cH",
				function()
					vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "x", false)
					vim.cmd("CodeSnapHighlightSave")
				end,
				mode = "v",
				desc = "Save snap (highlight)",
			},
			{
				"<leader>cH",
				function()
					vim.fn.setpos("'<", { 0, 1, 1, 0 })
					vim.fn.setpos("'>", { 0, vim.api.nvim_buf_line_count(0), 1, 0 })
					vim.cmd("CodeSnapHighlightSave")
				end,
				mode = "n",
				desc = "Save snap (highlight, whole buffer)",
			},
		},
		opts = {
			show_line_number = true,
			highlight_color = "#41486830",
			show_workspace = true,
			snapshot_config = {
				theme = "candy",
				window = {
					mac_window_bar = true,
					shadow = {
						radius = 20,
						color = "#00000060",
					},
					margin = { x = 82, y = 82 },
					border = {
						width = 1,
						color = "#bb9af730",
					},
					title_config = {
						color = "#c0caf5",
						font_family = "FantasqueSansM Nerd Font",
					},
				},
				themes_folders = {},
				fonts_folders = {},
				line_number_color = "#3b4261",
				command_output_config = {
					prompt = "❯",
					font_family = "FantasqueSansM Nerd Font",
					prompt_color = "#f7768e",
					command_color = "#9ece6a",
					string_arg_color = "#e0af68",
				},
				code_config = {
					font_family = "FantasqueSansM Nerd Font",
					breadcrumbs = {
						enable = true,
						separator = "/",
						color = "#565f89",
						font_family = "FantasqueSansM Nerd Font",
					},
				},
				watermark = {
					content = "Made by Pxnity",
					font_family = "FantasqueSansM Nerd Font",
					color = "#7aa2f7",
				},
				background = {
					start = { x = 0, y = 0 },
					["end"] = { x = "max", y = 0 },
					stops = {
						{ position = 0, color = "#1a1b26" },
						{ position = 1, color = "#24283b" },
					},
				},
			},
		},
		config = function(_, opts)
			require("codesnap").setup(opts)

			local cfg_module = require("codesnap.config")
			local static = require("codesnap.static")
			local gen_module = require("codesnap.module")

			-- NOTE: this used to re-implement the whole generator pipeline:
			-- the config was serialised to a fixed /tmp path and the Rust
			-- module was re-`require`d from a worker thread after scanning
			-- `package.cpath` for an entry ending in `generator.so`.
			-- `codesnap.module` registers its *libs directory* on
			-- `package.cpath` (as a `?` pattern), never the library file,
			-- so that lookup could never succeed and every CodeSnap command
			-- failed with "generator library not found in package.cpath".
			-- Upstream already loads the generator, so use it directly.

			-- `:CodeSnapSave` upstream requires the target path as an
			-- argument; prompt for it instead.
			vim.api.nvim_create_user_command("CodeSnapSave", function()
				vim.ui.input({ prompt = "Save snapshot to: ", default = vim.fn.expand("~/Pictures/codesnap.png") }, function(p)
					if not p or p == "" then
						return
					end
					require("codesnap").save(p)
				end)
			end, { nargs = "*", range = "%" })

			-- Upstream ships `CodeSnapHighlightSave` as a no-op. Implement it:
			-- highlight the whole buffer and write the snapshot to a file.
			vim.api.nvim_create_user_command("CodeSnapHighlightSave", function(args)
				local path = args.args
				if not path or path == "" then
					path = vim.fn.expand("~/Pictures/codesnap.png")
				end

				local ok, config = pcall(cfg_module.get_config)
				if not ok or not config or not config.content then
					vim.notify("CodeSnap: " .. tostring(config), vim.log.levels.ERROR)
					return
				end

				local lines = vim.split(config.content.content, "\n", { plain = true })
				config.content.highlight_lines = { { 1, #lines, static.config.highlight_color } }

				local generator = gen_module.generator
				if not generator then
					vim.notify("CodeSnap: generator not loaded", vim.log.levels.ERROR)
					return
				end

				local saved, err = pcall(generator.save, path, config)
				if not saved then
					vim.notify("CodeSnap: " .. tostring(err), vim.log.levels.ERROR)
					return
				end

				vim.cmd("delmarks <>")
				vim.notify("Snapshot saved to " .. path, vim.log.levels.INFO)
			end, { nargs = "*", range = "%" })
		end,
	},
}
