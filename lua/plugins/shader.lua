return {
	{
		"nvim-treesitter/nvim-treesitter",
		opts = function(_, opts)
			vim.filetype.add({
				extension = {
					glsl = "glsl",
					vert = "glsl",
					frag = "glsl",
					tesc = "glsl",
					tese = "glsl",
					geom = "glsl",
					comp = "glsl",
					hlsl = "hlsl",
					hlsli = "hlsl",
					fx = "hlsl",
					fxh = "hlsl",
					vsh = "hlsl",
					psh = "hlsl",
					wgsl = "wgsl",
				},
				filename = {
					["*.vert"] = "glsl",
					["*.frag"] = "glsl",
					["*.tesc"] = "glsl",
					["*.tese"] = "glsl",
					["*.geom"] = "glsl",
					["*.comp"] = "glsl",
					["*.vs"] = "hlsl",
					["*.ps"] = "hlsl",
					["*.gs"] = "hlsl",
					["*.cs"] = "hlsl",
				},
			})
		end,
	},
	-- NOTE: the `glsl_analyzer` server itself lives in `lua/plugins/lsp.lua`.
	-- Keeping a second `nvim-lspconfig` spec here meant two different
	-- definitions of the same server were deep-merged, which made it very
	-- easy to end up with a half-applied configuration.
}
