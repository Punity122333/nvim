local DisabledPlugins =
	{ {
		"folke/todo-comments.nvim",
		enabled = false,
	}, { "ThePrimeagen/harpoon", enabled = false }, {
		-- kulala.nvim (the HTTP client from the `util.rest` extra). Its
		-- Rust backend was never built, so it raised an error on every
		-- `Lazy! sync`. The rest of the extra (the `http` and `graphql`
		-- treesitter parsers) is kept.
		"mistweaverco/kulala.nvim",
		enabled = false,
	} }

return DisabledPlugins
