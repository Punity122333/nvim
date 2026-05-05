return {
	{
		"zbirenbaum/copilot.lua",
		opts = {
			suggestion = {
				enabled = false,
				auto_trigger = false,
        debounce = 300,
				keymap = {
					accept = false, -- handled by blink-cmp Tab keymap
					accept_word = false,
					accept_line = false,
					next = "<M-]>",
					prev = "<M-[>",
					dismiss = "<C-]>",
				},
			},
			panel = { enabled = false },
			cmp = { enabled = false },
		},
	},
}
