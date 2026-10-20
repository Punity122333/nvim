return {
  "ngtuonghy/live-server-nvim",
  -- cmd registers these commands instantly so Neovim knows they exist,
  -- but postpones loading the heavy logic until you actually use them.
  cmd = { "LiveServerStart", "LiveServerStop", "LiveServerToggle" },
  build = ":LiveServerInstall", 
  config = function()
    require("live-server-nvim").setup({})
  end,
}



