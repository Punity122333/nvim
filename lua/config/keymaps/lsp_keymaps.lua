-- LSP Keymaps
--
-- NOTE: `TSRestart` used to be defined here *and* in
-- `lua/config/keymaps/plugin_keymaps.lua`.  `nvim_create_user_command`
-- does not complain about a duplicate, it just replaces the old one, so
-- one of the two definitions was dead all along.  The command belongs to
-- the tree-sitter plugin and lives in `plugin_keymaps.lua` now.
vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, { desc = "Code Action" })
