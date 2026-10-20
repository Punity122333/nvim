vim.opt.rtp:prepend(vim.fn.expand("~/.local/share/nvim/site"))
local _ts_disable_cache = {}
return {
	
	{
		"nvim-treesitter/nvim-treesitter",
		lazy = false,
		build = ":TSUpdate",
		opts = {
			ensure_installed = {
				"c",
				"cpp",
				"lua",
				"vim",
				"vimdoc",
				"query",
				"typescript",
				"tsx",
				"javascript",
				"css",
				"scss",
				"html",
				"glsl",
				"hlsl",
				"wgsl",
			},
			sync_install = false,
			auto_install = false,
			highlight = {
				enable = true,
				additional_vim_regex_highlighting = false,
				disable = function(lang, buf)
					if vim.wo.diff then
						return true
					end
					local disabled_filetypes = {
						"help",
						"dashboard",
						"avante",
						"avante-input",
						"gitcommit",
						"markdown",
						"oil",
						"TelescopePrompt",
						"alpha",
						"NvimTree",
						"snacks_picker_list",
						"snacks_picker_preview",
					}
					local ft = vim.bo[buf].filetype
					for _, dft in ipairs(disabled_filetypes) do
						if ft == dft then
							return true
						end
					end

					if (lang == "c" or lang == "cpp") and vim.api.nvim_buf_line_count(buf) > 1000 then
						return true
					end
					local name = vim.api.nvim_buf_get_name(buf)
					local cached = _ts_disable_cache[name]
					if cached ~= nil then
						return cached
					end
					local ok, stats = pcall(vim.uv.fs_stat, name)
					if ok and stats and stats.size > 100 * 1024 then
						_ts_disable_cache[name] = true
						return true
					end
					return false
				end,
			},
			indent = { enable = true },
			incremental_selection = {
				enable = false,
				keymaps = {},
			},
		},
	},
	{ "nvim-treesitter/nvim-treesitter-textobjects", enabled = true, lazy = false },
}
