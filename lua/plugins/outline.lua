return {
  {
    "hedyhli/outline.nvim",
    -- `:Outline` is bound in `lua/config/keymaps/movement_keymaps.lua`
    -- (`<leader>O`). Without a `cmd` trigger the plugin was never loaded
    -- and the command did not exist.
    cmd = "Outline",
    opts = {
      providers = {
        priority = { "lsp", "markdown" }, -- removed treesitter
      },
      symbol_folding = {
        autofold_depth = 1,
      },
      outline_window = {
        position = "right",
        width = 25,
      },
    },
  },
}
