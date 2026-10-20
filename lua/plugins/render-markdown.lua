-- render-markdown.nvim is intentionally disabled: it is not installed and
-- therefore never loaded. It used to also be listed in
-- `lua/plugins/ui.lua` and as an avante dependency, which advertised a
-- plugin that could never run. The `pcall(require, "render-markdown")`
-- guard in `init.lua` and the `RenderMarkdownCode` highlight groups in
-- `lua/config/highlights.lua` are harmless no-ops while it stays off.
--
-- Flip `enabled` to `true` (and let lazy.nvim install it) to bring it
-- back, then re-add the avante dependency if you want markdown
-- rendering inside avante's sidebar.
return {
	{
		"MeanderingProgrammer/render-markdown.nvim",
		enabled = false,
	},
}
