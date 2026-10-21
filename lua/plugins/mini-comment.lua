-- mini.comment *without* tree-sitter.
--
-- The LazyVim extra (`lazyvim.plugins.extras.coding.mini-comment`) wires
-- `nvim-ts-context-commentstring` into mini.comment: the comment string is
-- then computed from the tree-sitter node under the cursor.  That has two
-- problems:
--
--   * it needs a tree-sitter parser for the language, so the comment string
--     is only available once the parser is installed *and* the buffer has
--     been parsed;
--   * computing it calls `vim.filetype.get_option(ft, 'commentstring')`,
--     and that call runs the *ftplugin* of `ft` in a temporary buffer, which
--     fires the `FileType` autocmds of that filetype.  A `FileType` autocmd
--     that fails (see `lua/config/autocmds.lua`) then breaks the whole
--     comment operation: `gcc` silently does nothing, and it only happens
--     for the *first* comment in a buffer, because the option is cached
--     afterwards.
--
-- The comment string is taken from the buffer's 'commentstring' option
-- instead - which is what mini.comment falls back to anyway.  No tree-sitter,
-- no temporary buffer, no autocmds.
return {
	{
		"nvim-mini/mini.comment",
		-- `lazy = false`: Neovim 0.12 has a built-in `gcc` that computes the
		-- comment string from tree-sitter.  mini.comment replaces that
		-- mapping, so it has to be in place before the first key press.
		lazy = false,
		opts = {
			options = {
				custom_commentstring = function()
					return vim.bo.commentstring
				end,
			},
		},
	},
	{
		-- The tree-sitter based comment string of the LazyVim extra is not
		-- used any more (see above).
		"JoosepAlviste/nvim-ts-context-commentstring",
		enabled = false,
	},
}
