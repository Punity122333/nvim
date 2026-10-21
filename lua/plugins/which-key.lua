-- Single definition of which-key. It used to be duplicated in
-- `lua/plugins/ui.lua`, where the two `delay` values (130 vs 300) and two
-- `timeoutlen` values contradicted each other. Kept at 300 to match
-- `vim.o.timeoutlen` in `lua/config/options.lua`.
--
-- NOTE: 'timeoutlen' and 'ttimeoutlen' are *not* set here.  They belong to
-- `lua/config/options.lua` (which is loaded before lazy.nvim starts), and
-- this `init` function used to overwrite 'ttimeoutlen' with 10ms - too
-- short for the "gc"/"gcc" disambiguation of the comment mappings.
return {
	"folke/which-key.nvim",
	lazy = false,
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
	config = function(_, opts)
		require("which-key").setup(opts)

		-- The trigger mappings that which-key registers for every prefix it
		-- knows ("g", "<leader>", ...) are created with `nowait = true`.
		-- That means the prefix key is swallowed *immediately*: Neovim does
		-- not even look whether a longer mapping matches.  The rest of the
		-- sequence is then a race between which-key's 50ms poll and
		-- Neovim's own input handling, and a fast "gcc" was sometimes eaten
		-- by the popup (the leftover keys then did something else
		-- entirely - e.g. "cc" changed the line).
		--
		-- Without `nowait`, Neovim waits for 'timeoutlen' first: a longer
		-- mapping ("gcc") wins, and the popup still shows up when the prefix
		-- is used on its own (which is what the popup is for).
		--
		-- NOTE: this patches which-key's internals, so it is guarded: if the
		-- API changes, the patch is simply skipped.
		local ok, Triggers = pcall(require, "which-key.triggers")
		if not ok or type(Triggers.add) ~= "function" then
			return
		end

		local add = Triggers.add
		Triggers.add = function(trigger)
			add(trigger)

			pcall(vim.api.nvim_buf_call, trigger.buf, function()
				local km = vim.fn.maparg(trigger.keys, trigger.mode, false, true)
				if not (km and km.desc and km.desc:find("which%-key%-trigger")) then
					return
				end

				-- Re-create the trigger without `nowait`.
				pcall(vim.keymap.del, trigger.mode, trigger.keys, { buffer = trigger.buf })
				vim.keymap.set(trigger.mode, trigger.keys, function()
					require("which-key.state").start({ keys = trigger.keys })
				end, {
					buffer = trigger.buf,
					desc = km.desc,
				})
			end)
		end
	end,
}
