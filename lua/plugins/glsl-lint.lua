local GlslangEvent = { "BufReadPre", "BufNewFile" }
local GlslangCmd = "glslangValidator"
local GlslangStream = "stderr"
local GlslangIgnoreExitcode = true

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
		event = GlslangEvent,
		config = function()
			local lint = require("lint")

			lint.linters.glslangValidator = {
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
			}

			lint.linters_by_ft = {
				glsl = { "glslangValidator" },
				vert = { "glslangValidator" },
				frag = { "glslangValidator" },
				tesc = { "glslangValidator" },
				tese = { "glslangValidator" },
				geom = { "glslangValidator" },
				comp = { "glslangValidator" },
			}

			local lint_augroup = vim.api.nvim_create_augroup("nvim_lint_glsl", { clear = true })

			-- 🔥 main lint triggers (low spam, high signal)
			vim.api.nvim_create_autocmd({ "BufWritePost", "InsertLeave" }, {
				group = lint_augroup,
				callback = function()
					local ft = vim.bo.filetype
					if lint.linters_by_ft[ft] then
						lint.try_lint()
					end
				end,
			})

			-- 😈 optional: debounced live linting while typing
			local timer = (vim.uv or vim.loop).new_timer()

			vim.api.nvim_create_autocmd("TextChanged", {
				group = lint_augroup,
				callback = function()
					local ft = vim.bo.filetype
					if not lint.linters_by_ft[ft] then
						return
					end

					timer:stop()
					timer:start(
						300,
						0,
						vim.schedule_wrap(function()
							lint.try_lint()
						end)
					)
				end,
			})
		end,
	},
}
