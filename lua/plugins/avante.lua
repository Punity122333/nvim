local _online_cache = nil
local _online_checked_at = 0
local _online_refreshing = false
local ONLINE_CACHE_TTL = 30000

local function refresh_online()
	if _online_refreshing then
		return
	end
	_online_refreshing = true
	vim.system(
		{ "curl", "-s", "--max-time", "1", "-o", "/dev/null", "-w", "%{http_code}", "https://1.1.1.1" },
		{ text = true },
		function(obj)
			_online_refreshing = false
			local code = obj.stdout or ""
			_online_cache = code ~= "" and code ~= "000"
			_online_checked_at = vim.uv.now()
		end
	)
end

local function is_online()
	local now = vim.uv.now()
	if _online_cache ~= nil and (now - _online_checked_at) < ONLINE_CACHE_TTL then
		return _online_cache
	end
	if _online_cache ~= nil then
		refresh_online()
		return _online_cache
	end
	refresh_online()
	return true
end

-- Avante draws its inline hints (e.g. " [<leader>aa: ask, <leader>ae: edit] ")
-- as virtual text. Neovim paints virtual text with the *default* (Normal)
-- background unless the extmark uses `hl_mode = "combine"`, so the hint ends
-- up as an opaque #1a1b26 block on top of the line. Avante does not expose
-- that option, so inject it into the extmarks it creates.
local AVANTE_INLINE_HINT = "AvanteInlineHint"

local function is_inline_hint(opts)
	if opts.hl_group == AVANTE_INLINE_HINT then
		return true
	end
	if type(opts.virt_text) ~= "table" then
		return false
	end
	for _, chunk in ipairs(opts.virt_text) do
		local hl = chunk[2]
		if hl == AVANTE_INLINE_HINT then
			return true
		end
		if type(hl) == "table" and vim.tbl_contains(hl, AVANTE_INLINE_HINT) then
			return true
		end
	end
	return false
end

local function patch_inline_hint_background()
	if vim.g.avante_inline_hint_patched then
		return
	end
	vim.g.avante_inline_hint_patched = true

	local orig = vim.api.nvim_buf_set_extmark
	---@diagnostic disable-next-line: duplicate-set-field
	vim.api.nvim_buf_set_extmark = function(buf, ns, row, col, opts)
		if type(opts) == "table" and is_inline_hint(opts) then
			opts = vim.tbl_extend("force", opts, { hl_mode = "combine" })
		end
		return orig(buf, ns, row, col, opts)
	end
end

return {
	{
		"yetone/avante.nvim",
    event = "VeryLazy",
		version = false,
		build = "make",
		opts = {
			notify = false,
			mode = "agentic",
			provider = "gemini",
			instructions_file = "avante.md",
			providers = {
				copilot = {
					endpoint = "https://api.githubcopilot.com",
					model = "gpt-4o",
					proxy = nil,
					allow_insecure_call = true,
					timeout = 5000,
				},
				-- Named copilot models below show up individually in the
				-- model selector (<leader>a? / :AvanteModels). A bare
				-- `copilot = {...}` block only ever exposes one model.
				["copilot/claude-sonnet-4.5"] = {
					__inherited_from = "copilot",
					model = "claude-sonnet-4.5",
					display_name = "copilot/claude-sonnet-4.5",
					extra_request_body = { max_tokens = 65536 },
				},
				["copilot/gpt-4.1"] = {
					__inherited_from = "copilot",
					model = "gpt-4.1",
					display_name = "copilot/gpt-4.1",
					extra_request_body = { max_tokens = 65536 },
				},
				["copilot/gemini-2.5-pro"] = {
					__inherited_from = "copilot",
					model = "gemini-2.5-pro",
					display_name = "copilot/gemini-2.5-pro",
					extra_request_body = { max_tokens = 65536 },
				},
				["copilot/o4-mini"] = {
					__inherited_from = "copilot",
					model = "o4-mini",
					display_name = "copilot/o4-mini",
					extra_request_body = { max_tokens = 65536 },
				},
			},
			behaviour = {
				enable_cursor_planning_mode = true,
				auto_suggestions = false,
				auto_set_highlight_group = true,
				auto_set_keymaps = true,
				auto_apply_diff_after_generation = false,
				support_paste_from_clipboard = false,
				notify = false,
			},
			input = {
				provider = "snacks",
			},
			mappings = {
				ask = "<leader>aa",
				edit = "<leader>ae",
				refresh = "<leader>aR",
				focus = "<leader>af",
				toggle = {
					default = "<leader>at",
					debug = "<leader>ad",
					hint = "<leader>ah",
					suggestion = "<leader>as",
					repology = "<leader>ar",
				},
			},
			windows = {
				position = "right",
				width = 23,
				wrap = true,
				sidebar_header = {
					enabled = true,
					align = "center",
					rounded = true,
				},
				border = "rounded",
				ask = {
					start_insert = false,
					border = "rounded",
				},
				edit = {
					border = "rounded",
				},
			},
			suggestion = {
				throttle = 1000,
				debounce = 500,
			},
		},
		config = function(_, opts)
			patch_inline_hint_background()
			require("avante").setup(opts)

			-- Avante renders markdown-ish content; treesitter highlighting it
			-- fights with the plugin's own rendering.
			vim.api.nvim_create_autocmd("FileType", {
				pattern = { "avante", "avante-input" },
				callback = function(ev)
					vim.treesitter.stop(ev.buf)
				end,
			})

			vim.api.nvim_create_autocmd("InsertEnter", {
				callback = function()
					if not is_online() then
						local ok, suggestion = pcall(require, "avante.suggestion")
						if ok and suggestion.stop then
							pcall(suggestion.stop)
						end
					end
				end,
			})

			vim.api.nvim_create_autocmd("User", {
				pattern = "AvantePostSetup",
				once = true,
				callback = function()
					local ok, suggestion = pcall(require, "avante.suggestion")
					if not ok then
						return
					end

					if suggestion._suggest then
						local original = suggestion._suggest
						suggestion._suggest = function(...)
							if not is_online() then
								return
							end
							-- pcall swallows whatever the original throws
							pcall(original, ...)
						end
					end
				end,
			})
		end,
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "stevearc/dressing.nvim",
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      "ColinKennedy/mega.cmdparse",
      "ColinKennedy/mega.logging",
      "nvim-tree/nvim-web-devicons",
      "zbirenbaum/copilot.lua",
      -- NOTE: render-markdown.nvim is disabled in
      -- `lua/plugins/render-markdown.lua`, so it is never installed and
      -- could never be loaded here. Listing it as a dependency only
      -- advertised a plugin that does not exist.
    },
  },
}

