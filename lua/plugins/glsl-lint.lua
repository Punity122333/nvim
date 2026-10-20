-- GLSL linting.
--
-- IMPORTANT: this spec deliberately does NOT define a `config` function.
-- A user `config` replaces LazyVim's nvim-lspconfig... nvim-lint config,
-- which is what registers the BufWritePost/BufReadPost/InsertLeave lint
-- autocmds and what seeds `lint.linters_by_ft` with LazyVim's defaults
-- (`fish`). Overriding it left *every* language except GLSL without a
-- single linter.
--
-- Everything is therefore expressed through `opts` (which is merged with
-- LazyVim's) and `init` (which runs in addition to LazyVim's config).
local GlslangCmd = "glslangValidator"
local GlslangStream = "stderr"
local GlslangIgnoreExitcode = true

-- The shader ftplugin maps every shader extension onto the "glsl"
-- filetype, so this is the only key that is ever matched. The rest are
-- kept as a safety net for files that are not remapped.
local GLSL_FILETYPES = {
	glsl = true,
	vert = true,
	frag = true,
	tesc = true,
	tese = true,
	geom = true,
	comp = true,
}

local GlslangStageMap = {
	vert = "vert",
	frag = "frag",
	tesc = "tesc",
	tese = "tese",
	geom = "geom",
	comp = "comp",
	glsl = "vert",
}

return {
	{
		"mfussenegger/nvim-lint",
		event = "LazyFile",
		-- Live linting while typing (debounced). LazyVim only lints on
		-- write/leave, this adds the "while typing" variant for shaders.
		init = function()
			local timer = (vim.uv or vim.loop).new_timer()

			vim.api.nvim_create_autocmd("TextChanged", {
				group = vim.api.nvim_create_augroup("nvim_lint_glsl_live", { clear = true }),
				callback = function()
					if not GLSL_FILETYPES[vim.bo.filetype] then
						return
					end

					local ok, lint = pcall(require, "lint")
					if not ok then
						return
					end

					timer:stop()
					timer:start(300, 0, vim.schedule_wrap(function()
						require("lint").try_lint()
					end))
				end,
			})
		end,
		opts = {
			linters = {
				glslangValidator = {
					cmd = GlslangCmd,
					stdin = false,
					args = function()
						local ext = vim.fn.expand("%:e")
						local stage = GlslangStageMap[ext] or "vert"
						return { "-S", stage, vim.api.nvim_buf_get_name(0) }
					end,
					stream = GlslangStream,
					ignore_exitcode = GlslangIgnoreExitcode,

					parser = function(output, bufnr)
						local diagnostics = {}

						for line in output:gmatch("[^\r\n]+") do
							local severity, file, lnum, msg = line:match("^(%w+):%s*(.-):%s*(%d+):%s*(.+)$")

							if severity and lnum and msg then
								local sev = vim.diagnostic.severity.ERROR
								if severity == "WARNING" then
									sev = vim.diagnostic.severity.WARN
								elseif severity == "INFO" then
									sev = vim.diagnostic.severity.INFO
								end

								diagnostics[#diagnostics + 1] = {
									lnum = tonumber(lnum) - 1,
									col = 0,
									end_lnum = tonumber(lnum) - 1,
									end_col = 0,
									message = msg:gsub("^'([^']+)'%s*:%s*", ""),
									severity = sev,
									source = "glslangValidator",
								}
							end
						end

						return diagnostics
					end,
				},
			},
			linters_by_ft = {
				glsl = { "glslangValidator" },
				vert = { "glslangValidator" },
				frag = { "glslangValidator" },
				tesc = { "glslangValidator" },
				tese = { "glslangValidator" },
				geom = { "glslangValidator" },
				comp = { "glslangValidator" },
			},
		},
	},
}
