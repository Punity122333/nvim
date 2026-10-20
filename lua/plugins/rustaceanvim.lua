-- NOTE: this used to use a `config` function. A user `config` *replaces* the
-- one from the LazyVim `lang.rust` extra, which silently dropped the extra's
-- codelldb DAP adapter and its `<leader>cR` / `<leader>dr` mappings.
-- Using `opts` instead merges with the extra and keeps its `config` running.
return {
	"mrcjkb/rustaceanvim",
	version = "^8",
	ft = { "rust" },
	opts = function(_, opts)
		local ok_snacks, snacks = pcall(require, "snacks")

		-- blink's LSP capabilities (snippet support, fuzzy matching, ...)
		local capabilities = vim.lsp.protocol.make_client_capabilities()
		local ok_blink, blink = pcall(require, "blink.cmp")
		if ok_blink then
			capabilities = blink.get_lsp_capabilities(capabilities)
		end

		-- `lua/config/autocmds.lua` forces `utf-8` for rust-analyzer, so
		-- utf-8 has to be advertised first, otherwise the server picks
		-- utf-16 (the global default of `servers["*"]`) and the client
		-- would decode utf-16 positions as utf-8.
		capabilities.general = capabilities.general or {}
		capabilities.general.positionEncodings = { "utf-8", "utf-16", "utf-32" }

		-- Semantic tokens are disabled globally (see `lua/plugins/lsp.lua`).
		-- These capabilities are built from scratch here, so the global
		-- `servers["*"]` opt-out does not apply to rust-analyzer on its own.
		-- `vim.NIL` (JSON `null`), not `false`: rust-analyzer aborts the
		-- session on a boolean.
		capabilities.textDocument = capabilities.textDocument or {}
		capabilities.textDocument.semanticTokens = vim.NIL

		-- rustaceanvim merges `vim.lsp.config["rust-analyzer"]` *over* its
		-- own server config, so the capabilities have to be registered
		-- there as well, otherwise the global `servers["*"]` capabilities
		-- would replace blink's.
		vim.lsp.config("rust-analyzer", {
			capabilities = capabilities,
		})

		opts.server = opts.server or {}

		-- Keep the extra's `on_attach` (it adds the `<leader>cR` and
		-- `<leader>dr` mappings) and add the flyCheck debounce on top.
		local extra_on_attach = opts.server.on_attach
		opts.server.on_attach = function(client, bufnr)
			if extra_on_attach then
				extra_on_attach(client, bufnr)
			end

			-- How long to wait after the last edit/cursor movement before
			-- running `cargo check` (flyCheck). The rust-analyzer settings
			-- below have `checkOnSave = false`, so this is the only thing
			-- that produces diagnostics.
			local DELAY_MS = 1200
			local timer = vim.uv.new_timer()

			client.server_capabilities.semanticTokensProvider = nil
			-- NOTE: `TextChangedI` is included so that the check also runs
			-- while typing - `CursorMovedI` alone only fires when the
			-- cursor is moved, not when text is inserted.
			vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI", "TextChangedI" }, {
				buffer = bufnr,
				desc = "rust-analyzer: debounced flyCheck on cursor idle",
				callback = function()
					timer:stop()
					timer:start(
						DELAY_MS,
						0,
						vim.schedule_wrap(function()
							if not vim.lsp.buf_is_attached(bufnr, client.id) then
								return
							end
							if vim.fn.exists(":RustLsp") ~= 2 then
								return
							end
							vim.cmd.RustLsp({ "flyCheck", "run" })
							if
								ok_snacks
								and snacks.explorer
								and type(snacks.explorer.refresh) == "function"
							then
								snacks.explorer.refresh()
							end
						end)
					)
				end,
			})

			vim.api.nvim_buf_attach(bufnr, false, {
				on_detach = function()
					if not timer:is_closing() then
						timer:stop()
						timer:close()
					end
				end,
			})
		end

		opts.server.capabilities = capabilities

		opts.server.settings = {
			["rust-analyzer"] = {
				numThreads = 4,
				cachePriming = {
					numThreads = 2,
				},
				files = {
					excludeDirs = { ".git", "node_modules", "target" },
				},
				cargo = {
					buildScripts = { enable = false },
					allTargets = false,
				},
				procMacro = {
					enable = true,
				},
				checkOnSave = false,
				diagnostics = {
					experimental = { enable = false },
				},
				completion = {
					fullFunctionSignatures = { enable = false },
				},
			},
		}

		return opts
	end,
}
