-- OpenCode integration: https://github.com/nickjvandyke/opencode.nvim
--
-- The plugin finds the running opencode daemon on its own, so there is no
-- server URL or credential to configure. It gives you:
--   * ask     - a prompt with editor context (@this, @buffer, @diagnostics, ...)
--   * select  - a picker with the built-in prompts (explain, fix, implement, ...)
--   * prompt  - send a prompt to the current session
--   * accept/reject of the edits opencode makes (via a diffpatch view)
--
-- The `snacks.input` and `snacks.picker` integrations are already enabled
-- in `lua/plugins/snacks.lua`, so `ask`/`select` get the full picker UI.
return {
	"nickjvandyke/opencode.nvim",
	config = function()
		-- The plugin reads `vim.g.opencode_opts` when it loads and merges it
		-- with its defaults.  `opencode.Opts` is declared by the plugin
		-- itself, but that lives in the `lazy` directory, which the lua_ls
		-- workspace ignores - so the type cannot be resolved here.
		---@diagnostic disable-next-line: undefined-doc-name
		---@type opencode.Opts
		vim.g.opencode_opts = {}
	end,
	-- NOTE: the plugin's README suggests <C-a> / <C-x>, but those are
	-- taken by the `dial` extra (increment / decrement), so the mappings
	-- live under <leader> instead.
	--
	-- The mappings are declared as `keys` (and not inside `config`) so
	-- that lazy.nvim registers them right away and loads the plugin on
	-- the first key press - a plugin with only a `config` would never be
	-- loaded at all.
	keys = {
		{
			"<leader>oa",
			function()
				require("opencode").ask("@this: ")
			end,
			mode = { "n", "x" },
			desc = "Ask OpenCode",
		},
		{
			"<leader>os",
			function()
				require("opencode").select()
			end,
			mode = { "n", "x" },
			desc = "Select OpenCode",
		},
		{
			"<leader>op",
			function()
				require("opencode").prompt()
			end,
			mode = { "n", "x" },
			desc = "Prompt OpenCode",
		},
	},
}
