return {
  "ngtuonghy/live-server-nvim",
  event = "VeryLazy",
  build = ":LiveServerInstall", -- Installs local dependencies if needed
  config = function()
    require("live-server-nvim").setup({})
  end,
}

