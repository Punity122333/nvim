return {
	"folke/snacks.nvim",
	priority = 1000,
	lazy = false,
	opts = {
		scratch = {
			enabled = true,
			win = {
				layout = {
					position = "center",
					width = 0.5,
					height = 0.5,
					backdrop = false,
				},
				backdrop = false,
			},
		},

		scope = { enabled = false },
		explorer = {
			enabled = true,
			cycle = false,
      follow = true,
      follow_file = true,
			git_status = false,
			win = {
				layout = {
					position = "right",
					width = 0.10,
				},
			},
			layout = {
				width = 0.10,
			},
		},
		styles = {
			backdrop = {
				transparent = false,
				blend = 0,
			},
		},
		picker = {
			enabled = true,
			ui_select = true,
			icons = {
				selected = "󰄲 ",
				unselected = "󰄱 ",
				cursor = "❯ ",
			},
			layout = {
				preset = "default",
				preview = false,
				layout = {
					backdrop = false,
				},
			},
			exclude = {
				".git",
				"node_modules",
				"**/*.lock",
				"package.json",
			},
			sources = {
				grep = {
					finder = function(opts, ctx)
						if #(ctx.filter.search or "") < 3 then
							return {}
						end
						return require("snacks.picker.source.grep").grep(opts, ctx)
					end,
				},
				explorer = {
					hidden = true,
					ignored = true,
					win = {
						list = {
							keys = {
								["<C-x>"] = "clear_selection",
							},
						},
					},
					layout = {

						layout = {
							width = 0.16,
							min_width = 0.15,
						},
					},
				},
			},
		},
		input = { enabled = true, prompt = " " },

		indent = {
			animate = {
				enabled = false,
			},
		},
		scroll = { enabled = false },
		words = { enabled = false },
		statuscolumn = { enabled = false },
		image = {
			enabled = true,
			math = { enabled = false },
			-- "pdf" is dropped on purpose: pdfreader.nvim owns .pdf buffers
			-- (paging, text mode, bookmarks, TOC), and snacks.image would
			-- otherwise hijack the same buffer via its own BufReadCmd.
			formats = {
				"png",
				"jpg",
				"jpeg",
				"gif",
				"bmp",
				"webp",
				"tiff",
				"heic",
				"avif",
				"mp4",
				"mov",
				"avi",
				"mkv",
				"webm",
				"icns",
			},
		},
	},
	keys = {

		{
			"<leader>e",
			function()
				Snacks.explorer()
			end,
			desc = "Toggle Explorer",
		},

		{
			"<leader>i",
			function()
				Snacks.image.hover()
			end,
			desc = "Image Hover",
		},
	},
}
