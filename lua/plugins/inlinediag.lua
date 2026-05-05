return {
	"rachartier/tiny-inline-diagnostic.nvim",
	event = "LspAttach",
	priority = 1000,
	config = function()
		vim.diagnostic.config({ virtual_text = false })
		require("tiny-inline-diagnostic").setup({
			preset = "modern",
			options = {
				multilines = {
					enabled = true,
					always_show = true,
				},
				show_source = false,
				enable_on_insert = false,
				throttle = 1500,
				overflow = { mode = "truncate" },
				max_width = 60,
			},
		})
		local ns = vim.api.nvim_create_namespace("cursor_line_diag_patch")
		local diag_id = 1337
		local cap_l = "\xee\x82\xb6"
		local cap_r = "\xee\x82\xb4"
		local sev_names = {
			[vim.diagnostic.severity.ERROR] = "Error",
			[vim.diagnostic.severity.WARN] = "Warn",
			[vim.diagnostic.severity.INFO] = "Info",
			[vim.diagnostic.severity.HINT] = "Hint",
		}
		local hl_map = {
			[vim.diagnostic.severity.ERROR] = "TinyInlineDiagnosticVirtualTextError",
			[vim.diagnostic.severity.WARN] = "TinyInlineDiagnosticVirtualTextWarn",
			[vim.diagnostic.severity.INFO] = "TinyInlineDiagnosticVirtualTextInfo",
			[vim.diagnostic.severity.HINT] = "TinyInlineDiagnosticVirtualTextHint",
		}
		local function int_to_hex(int)
			if not int then
				return nil
			end
			return string.format("#%06x", int)
		end
		local function setup_patch_hls()
			local comment_fg = int_to_hex(vim.api.nvim_get_hl(0, { name = "Comment", link = false }).fg)
			for sev, hl_name in pairs(hl_map) do
				local name = sev_names[sev]
				local body_bg = int_to_hex(vim.api.nvim_get_hl(0, { name = hl_name, link = false }).bg)
				vim.api.nvim_set_hl(0, "CursorDiagArrow" .. name, { fg = comment_fg })
				vim.api.nvim_set_hl(0, "CursorDiagCapL" .. name, { fg = body_bg })
				vim.api.nvim_set_hl(0, "CursorDiagCapR" .. name, { fg = body_bg })
			end
		end
		vim.schedule(setup_patch_hls)
		vim.api.nvim_create_autocmd("ColorScheme", {
			callback = function()
				vim.schedule(setup_patch_hls)
			end,
		})

		local tid = require("tiny-inline-diagnostic")
		local _uv = vim.uv or vim.loop
		local _tid_timer = _uv.new_timer()
		local _hold_timer = _uv.new_timer()
		local _holding = false
		local _in_insert = false
		local last_line = -1

		local function render_cursor_diag()
			-- never render while in insert mode; tiny-inline-diagnostic handles that
			if _in_insert then
				return
			end
			local buf = vim.api.nvim_get_current_buf()
			if vim.bo[buf].filetype == "lazy" then
				return
			end
			local ok, pos = pcall(vim.api.nvim_win_get_cursor, 0)
			if not ok then
				return
			end
			local line = pos[1] - 1
			local diags = vim.diagnostic.get(buf, { lnum = line })
			if #diags == 0 then
				pcall(vim.api.nvim_buf_del_extmark, buf, ns, diag_id)
				return
			end
			table.sort(diags, function(a, b)
				return a.severity < b.severity
			end)
			local diag = diags[1]
			local msg = diag.message:gsub("\n", " ")
			if #msg > 60 then
				msg = msg:sub(1, 60) .. "…"
			end
			local name = sev_names[diag.severity]
			local hl = hl_map[diag.severity]
			vim.api.nvim_buf_set_extmark(buf, ns, line, 0, {
				id = diag_id,
				virt_text = {
					{ " ←   ", "CursorDiagArrow" .. name },
					{ cap_l, "CursorDiagCapL" .. name },
					{ " ● " .. msg .. " ", hl },
					{ cap_r, "CursorDiagCapR" .. name },
				},
				virt_text_pos = "eol",
				hl_mode = "combine",
				priority = 999,
			})
		end

		-- tiny-inline-diagnostic registers a buffer-local ModeChanged autocmd in
		-- "TinyInlineDiagnosticAutocmds" on every LspAttach. Clear it now and
		-- re-clear after each future LspAttach (scheduled so we run after the plugin).
		local function clear_tid_modechanged()
			pcall(vim.api.nvim_clear_autocmds, {
				event = "ModeChanged",
				group = "TinyInlineDiagnosticAutocmds",
			})
		end
		vim.schedule(clear_tid_modechanged)
		vim.api.nvim_create_autocmd("LspAttach", {
			callback = function()
				vim.schedule(clear_tid_modechanged)
			end,
		})

		vim.api.nvim_create_autocmd("InsertLeave", {
			callback = function()
				_in_insert = false
				_tid_timer:stop()
				_tid_timer:start(800, 0, vim.schedule_wrap(function()
					if not _in_insert then
						tid.enable()
						render_cursor_diag()
					end
				end))
			end,
		})

		vim.api.nvim_create_autocmd("InsertEnter", {
			callback = function()
				_in_insert = true
				_hold_timer:stop()
				_holding = false
				_tid_timer:stop()
				_tid_timer:start(800, 0, vim.schedule_wrap(function()
					if _in_insert then
						tid.disable()
						local buf = vim.api.nvim_get_current_buf()
						pcall(vim.api.nvim_buf_del_extmark, buf, ns, diag_id)
					end
				end))
			end,
		})

		vim.on_key(function()
			if _in_insert then
				return
			end
			_holding = true
			_hold_timer:stop()
			_hold_timer:start(120, 0, vim.schedule_wrap(function()
				_holding = false
				render_cursor_diag()
			end))
		end)

		vim.api.nvim_create_autocmd("WinLeave", {
			callback = function()
				local buf = vim.api.nvim_get_current_buf()
				pcall(vim.api.nvim_buf_del_extmark, buf, ns, diag_id)
			end,
		})

		vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
			callback = function()
				local curr_line = vim.api.nvim_win_get_cursor(0)[1]
				if curr_line ~= last_line then
					pcall(vim.api.nvim_buf_del_extmark, 0, ns, diag_id)
					last_line = curr_line
					if not _holding and not _in_insert then
						render_cursor_diag()
					end
				end
			end,
		})

		vim.api.nvim_create_autocmd("DiagnosticChanged", {
			callback = function()
				if not _holding and not _in_insert then
					render_cursor_diag()
				end
			end,
		})
	end,
}













