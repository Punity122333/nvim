-- NOTE: this file used to hold a second `folke/tokyonight.nvim`,
-- `folke/which-key.nvim`, `MeanderingProgrammer/render-markdown.nvim` and
-- `yetone/avante.nvim` spec. Because lazy.nvim imports `lua/plugins/*.lua`
-- in alphabetical order and the *last* fragment wins for `opts`/`config`,
-- those duplicates silently replaced the real definitions:
--   * tokyonight  -> ui.lua's 4-line `on_highlights` won, so ~30 lines of
--                    colour customisation in colorscheme.lua were dead
--   * avante      -> ui.lua's `config` won, so avante.lua's `config` was dead
--   * which-key   -> which-key.lua's `delay` won, ui.lua's won on `init`
-- Each of those now lives in exactly one place.
return {
	{
		"LazyVim/LazyVim",
		opts = {
			colorscheme = "tokyonight",
		},
	},
}
