local DashboardSections = {
	{ section = "header" },
	{ section = "keys", gap = 1, padding = 1 },
	{ section = "startup" },
}
local DashboardHeader = [[
██╗    ██╗███████╗██╗      ██████╗ ██████╗ ███╗   ███╗███████╗
██║    ██║██╔════╝██║     ██╔════╝██╔═══██╗████╗ ████║██╔════╝
██║ █╗ ██║█████╗  ██║     ██║     ██║   ██║██╔████╔██║█████╗  
██║███╗██║██╔══╝  ██║     ██║     ██║   ██║██║╚██╔╝██║██╔══╝  
╚███╔███╔╝███████╗███████╗╚██████╗╚██████╔╝██║ ╚═╝ ██║███████╗
 ╚══╝╚══╝ ╚══════╝╚══════╝ ╚═════╝ ╚═════╝ ╚═╝     ╚═╝╚══════╝
      ██████╗ ██╗  ██╗███╗   ██╗██╗████████╗██╗   ██╗         
      ██╔══██╗╚██╗██╔╝████╗  ██║██║╚══██╔══╝╚██╗ ██╔╝         
      ██████╔╝ ╚███╔╝ ██╔██╗ ██║██║   ██║    ╚████╔╝          
      ██╔═══╝  ██╔██╗ ██║╚██╗██║██║   ██║     ╚██╔╝            
      ██║     ██╔╝ ██╗██║ ╚████║██║   ██║      ██║     ██╗    
      ╚═╝     ╚═╝  ╚═╝╚═╝  ╚═══╝╚═╝   ╚═╝      ╚═╝     ╚═╝     ]]

return {
	"folke/snacks.nvim",
	opts = {
		dashboard = {
			enabled = true,
			sections = DashboardSections,
			preset = {
				header = DashboardHeader,
				keys = {
					{
						icon = " ",
						key = "f",
						desc = "Find File",
						action = function()
							require("snipe.nav").files()
						end,
					},
					{
						icon = " ",
						key = "g",
						desc = "Find Text",
						action = function()
							require("snipe.rg").rg()
						end,
					},
					{
						icon = " ",
						key = "r",
						desc = "Recent Files",
						action = function()
							require("snipe.nav").oldfiles()
						end,
					},
					{
						icon = "󰉋 ",
						key = "p",
						desc = "Projects",
						action = function()
							require("snipe.nav").projects()
						end,
					},
					{ icon = " ", key = "n", desc = "New File", action = ":ene | startinsert" },
					{ icon = "⚙ ", key = "c", desc = "Config", action = function() require("snipe.nav").config_files() end }, -- beyond snipe
					{ icon = " ", key = "s", desc = "Restore Session", action = function() require("persistence").load() end }, -- beyond snipe
					{ icon = "󰒲 ", key = "x", desc = "Lazy Extras", action = ":LazyExtras" },
					{ icon = "󰒲 ", key = "l", desc = "Lazy", action = ":Lazy" },
					{ icon = " ", key = "q", desc = "Quit", action = ":qa" },
				},
			},
		},
	},
	specs = {
		{
			"folke/snacks.nvim",
			opts = function(_, opts)
				vim.api.nvim_set_hl(0, "SnacksDashboardHeader", { fg = "#7aa2f7", bold = true })
			end,
		},
	},
}