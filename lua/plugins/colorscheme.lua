local TOKYONIGHT_STYLE = "night"
local TOKYONIGHT_TRANSPARENT = false
local TOKYONIGHT_DIM_INACTIVE = false
local SIDEBARS_STYLE = "normal"
local FLOATS_STYLE = "normal"
local NIGHT_BG = "#1a1b26"
local STATUSLINE_BG = "#16161e"
local LIGHT_BLUE = "#82aaff"
local SOLID_BG = { bg = NIGHT_BG, blend = 0 }
local BORDER_HIGHLIGHT = "border_highlight"

return {
	{
		"folke/tokyonight.nvim",
		lazy = false,
		priority = 1000,
		opts = {
			style = TOKYONIGHT_STYLE,
			transparent = TOKYONIGHT_TRANSPARENT,
			dim_inactive = TOKYONIGHT_DIM_INACTIVE,
			styles = {
				sidebars = SIDEBARS_STYLE,
				floats = FLOATS_STYLE,
			},
			on_colors = function(c)
				c.bg_statusline = STATUSLINE_BG
			end,
			on_highlights = function(hl, c)
				hl["@variable"] = { fg = LIGHT_BLUE }
				hl["@variable.builtin"] = { fg = LIGHT_BLUE }
				hl["@variable.parameter"] = { fg = LIGHT_BLUE }
				hl["@variable.member"] = { fg = LIGHT_BLUE }
				hl["@property"] = { fg = LIGHT_BLUE }
				hl["@field"] = { fg = LIGHT_BLUE }
				hl["@identifier"] = { fg = LIGHT_BLUE }
				hl["@lsp.type.variable"] = { fg = LIGHT_BLUE }
				hl["@lsp.type.parameter"] = { fg = LIGHT_BLUE }
				hl["@lsp.type.property"] = { fg = LIGHT_BLUE }
				hl.Normal = SOLID_BG
				hl.NormalNC = SOLID_BG
				hl.NormalSB = SOLID_BG
				hl.NormalFloat = SOLID_BG
				hl.FloatBorder = { bg = NIGHT_BG, fg = c[BORDER_HIGHLIGHT], blend = 0 }
				hl.FloatTitle = { bg = NIGHT_BG, fg = LIGHT_BLUE, blend = 0 }
				hl.SnacksBackdrop = { bg = NIGHT_BG, blend = 0 }
				hl.TelescopeBackdrop = { bg = NIGHT_BG, blend = 0 }
				hl.TelescopeNormal = SOLID_BG
				hl.TelescopeBorder = { bg = NIGHT_BG, fg = c[BORDER_HIGHLIGHT], blend = 0 }
				hl.TelescopePromptNormal = SOLID_BG
				hl.TelescopePromptBorder = { bg = NIGHT_BG, fg = c[BORDER_HIGHLIGHT], blend = 0 }
				hl.TelescopeResultsNormal = SOLID_BG
				hl.TelescopePreviewNormal = SOLID_BG
				hl.BufferLineSeparator = { fg = NIGHT_BG, bg = NIGHT_BG }
				-- Keep the chrome on the page background.
				hl.SignColumn = { bg = "none" }
				hl.LineNr = { bg = "none" }
				hl.StatusLine = { bg = "none" }
				hl.EndOfBuffer = { bg = "none" }
			end,
		},
	},
}
