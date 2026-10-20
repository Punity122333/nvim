local ImmediateSaveEvents = { "BufLeave", "FocusLost" }
local DeferSaveEvents = {}
local CancelDeferredSaveEvents = {}
local DebounceDelay = 20000

return {
	{
		"okuuva/auto-save.nvim",
		event = { "InsertLeave", "BufReadPre" },
		opts = {
			enabled = true,
			trigger_events = {
				immediate_save = ImmediateSaveEvents,
				defer_save = DeferSaveEvents,
				cancel_deferred_save = CancelDeferredSaveEvents,
			},
			debounce_delay = DebounceDelay,
			condition = function(buffer)
				local mode = vim.api.nvim_get_mode().mode
				if mode == "no" or mode == "i" or mode == "v" or mode == "c" then
					return false
				end

				if vim.snippet and vim.snippet.active({ direction = 1 }) then
					return false
				end
				local utils = require("auto-save.utils.data")

				local ft = vim.bo[buffer].filetype
				local ExcludedFiletypes = { "gitcommit", "gitrebase", "hgcommit", "oil" }

				if vim.bo[buffer].modifiable and utils.not_in(ft, ExcludedFiletypes) then
					return true
				end
				return false
			end,
			noautocmd = true,
			write_all_buffers = false,
		},
	},
}
