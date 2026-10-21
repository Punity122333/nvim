-- LSP setup.
--
-- IMPORTANT: this spec deliberately does NOT define a `config` function.
-- In lazy.nvim a user `config` *replaces* the one from LazyVim, and
-- LazyVim's nvim-lspconfig `config` is what wires up:
--   * mason-lspconfig (`ensure_installed` + `automatic_enable`)
--   * `vim.lsp.config("*", servers["*"])`  (global capabilities)
--   * LazyVim's default LSP keymaps (gd, gr, gI, gy, gD, gK, <c-k>,
--     <leader>cr, <leader>cA, <leader>co, <leader>cc, ]] , [[ , ...)
--   * the LSP formatter registration, inlay hints and folding
-- Overriding it silently killed all of the above, so everything here is
-- expressed as `opts.servers` entries only.
--
-- The diagnostic debounce lives in `init` (which runs *in addition to*
-- LazyVim's `config`) so that it cannot replace it.
local OFFSET_ENCODING = "utf-16"

return {
	{
		"neovim/nvim-lspconfig",
		cond = function()
			return vim.env.KITTY_SCROLLBACK_NVIM ~= "true"
		end,
		event = { "BufReadPost" },
		dependencies = {
			"mason.nvim",
		},
		-- Collapse the diagnostic flood.
		--  * lua_ls publishes diagnostics for the whole workspace on every
		--    keystroke, so its pushes are collapsed into a single callback
		--    800ms after the last one.
		--  * every other server is debounced by 'updatetime'.
		--  * basedpyright is *pulled*, and every pull makes it re-check the
		--    file, so the pulls are debounced by 1200ms (the same interval
		--    the rust-analyzer flyCheck uses).
		init = function()
			-- Turn off LSP semantic tokens for every client.
			--
			-- The `capabilities.textDocument.semanticTokens = vim.NIL` in
			-- `servers["*"]` (see below) only stops the *server* from
			-- offering the feature. This stops *Neovim* from asking for the
			-- tokens and from applying the highlights, which is what
			-- actually removes the semantic colouring. Both halves are
			-- needed:
			--  * client side: no request, no extmarks, no redraw churn
			--  * server side: the server does not do the work at all
			vim.lsp.semantic_tokens.enable(false)

			-- Debounce the *pull* diagnostics of basedpyright.
			--
			-- basedpyright (like pyright) uses the pull model: it never
			-- pushes diagnostics, the client has to ask for them with
			-- `textDocument/diagnostic`. Neovim does that automatically
			-- on every `textDocument/didChange` (see
			-- `vim.lsp.diagnostic._enable`), so the type checker re-analyses
			-- the file on every single keystroke - and twice at that,
			-- because basedpyright answers with a
			-- `workspace/diagnostic/refresh` request that triggers yet
			-- another pull.
			--
			-- rust-analyzer is configured the other way round in
			-- `lua/plugins/rustaceanvim.lua`: `checkOnSave = false` plus a
			-- debounced `flyCheck` that only runs once the user has been
			-- idle for a moment. This does the same for basedpyright:
			-- the pull request is postponed until the file has been quiet
			-- for the delay below, which is the same interval the
			-- rust-analyzer flyCheck uses.
			--
			-- Add a server here to debounce its pull diagnostics as well.
			local PULL_DEBOUNCE_MS = {
				basedpyright = 1200,
			}

			-- Guard against wrapping twice (the plugin can be reloaded).
			local debounce = vim.lsp.diagnostic.__pull_debounce
			if not debounce then
				debounce = { orig = vim.lsp.diagnostic._refresh, timers = {} }
				vim.lsp.diagnostic.__pull_debounce = debounce

				vim.lsp.diagnostic._refresh = function(bufnr, client_id, only_visible)
					bufnr = vim._resolve_bufnr(bufnr)

					-- Find the client of this buffer that has its pull
					-- diagnostics debounced. If there is none, refresh as
					-- usual.
					local client, delay
					for _, c in ipairs(vim.lsp.get_clients({ bufnr = bufnr, method = "textDocument/diagnostic" })) do
						delay = PULL_DEBOUNCE_MS[c.name]
						if delay then
							client = c
							break
						end
					end

					if not client then
						return debounce.orig(bufnr, client_id, only_visible)
					end

					-- Restart the timer: only the last refresh of a burst
					-- is actually sent to the server.
					if debounce.timers[bufnr] then
						debounce.timers[bufnr]:stop()
						debounce.timers[bufnr] = nil
					end
					debounce.timers[bufnr] = vim.defer_fn(function()
						debounce.timers[bufnr] = nil
						if not vim.api.nvim_buf_is_valid(bufnr) then
							return
						end
						if not vim.lsp.buf_is_attached(bufnr, client.id) then
							return
						end
						-- `only_visible = false`: the check runs even when
						-- the buffer is not the current one, so the
						-- diagnostics are up to date when the user switches
						-- back to it (the rust-analyzer flyCheck behaves
						-- the same way).
						debounce.orig(bufnr, client.id, false)
					end, delay)
				end
			end

			local orig = vim.lsp.handlers["textDocument/publishDiagnostics"]
			if not orig then
				return
			end

			local lua_ls_timer = nil
			local timers = {}

			vim.lsp.handlers["textDocument/publishDiagnostics"] = function(err, result, ctx, cfg)
				local client = ctx and ctx.client_id and vim.lsp.get_client_by_id(ctx.client_id)
				local is_lua_ls = client and client.name == "lua_ls"

				if is_lua_ls then
					if lua_ls_timer then
						lua_ls_timer:stop()
					end
					lua_ls_timer = vim.defer_fn(function()
						lua_ls_timer = nil
						orig(err, result, ctx, cfg)
					end, 800)
					return
				end

				if not result then
					return orig(err, result, ctx, cfg)
				end

				local bufnr = vim.uri_to_bufnr(result.uri)
				local key = bufnr .. "_" .. (ctx.client_id or 0)
				if timers[key] then
					timers[key]:stop()
				end
				timers[key] = vim.defer_fn(function()
					timers[key] = nil
					orig(err, result, ctx, cfg)
				end, vim.o.updatetime)
			end
		end,
		opts = {
			-- Inlay hints are disabled for every language.
			-- LazyVim enables them by default (`inlay_hints.enabled = true`)
			-- and registers a `textDocument/inlayHint` handler that turns
			-- them on for every buffer. Setting `enabled = false` here
			-- stops that handler from ever being registered, so no server
			-- can request hints.
			inlay_hints = {
				enabled = false,
			},
			diagnostics = {
				update_in_insert = false,
				underline = true,
				severity_sort = true,
				virtual_text = {
					spacing = 4,
					prefix = "●",
				},
				float = {
					border = "rounded",
					source = "always",
				},
			},
			servers = {
				-- Global settings.
				--
				-- `config/autocmds.lua` forces `client.offset_encoding` to
				-- utf-16 for every client, so utf-16 has to be advertised
				-- first: the server picks the first encoding it supports
				-- out of `capabilities.general.positionEncodings` and
				-- reports it back, and that is what ends up in
				-- `client.offset_encoding`.
				["*"] = {
					capabilities = {
						general = {
							positionEncodings = { OFFSET_ENCODING, "utf-8" },
						},
						-- Semantic tokens are off.
						--
						-- These capabilities are merged *over* the defaults
						-- from `vim.lsp.protocol.make_client_capabilities()`,
						-- so the entry below replaces the whole
						-- `textDocument.semanticTokens` table.
						--
						-- `vim.NIL` is encoded as JSON `null`, which every
						-- server reads as "the client does not support
						-- semantic tokens". `false` must NOT be used here:
						-- rust-analyzer (serde) aborts the whole session with
						-- "invalid type: boolean `false`, expected struct
						-- SemanticTokensClientCapabilities".
						textDocument = {
							semanticTokens = vim.NIL,
						},
					},
				},

				-- ── explicitly disabled ────────────────────────────────
				-- The python/R extras enable a competing server by
				-- default. Pin them off so the servers below are the
				-- only ones that run. `enabled = false` also excludes them
				-- from mason-lspconfig's `automatic_enable`.
				--
				-- NOTE: the typescript extras (biome / oxc / tsc) are not
				-- enabled any more, so the entries for them are gone. The
				-- deprecated `tsserver` / `ts_ls` aliases stay disabled.
				tsserver = { enabled = false },
				ts_ls = { enabled = false },
				ruff = { enabled = false },
				ruff_lsp = { enabled = false },
				pyright = { enabled = false },
				r_language_server = { enabled = false },

				-- ── typescript ─────────────────────────────────────────
				vtsls = {
					enabled = true,
					mason = false,
					filetypes = {
						"javascript",
						"javascriptreact",
						"javascript.jsx",
						"typescript",
						"typescriptreact",
						"typescript.tsx",
					},
					settings = {
						complete_function_calls = true,
						vtsls = {
							enableMoveToFileCodeAction = true,
							autoUseWorkspaceTsdk = true,
							experimental = {
								completion = {
									enableServerSideFuzzyQuery = true,
								},
							},
						},
						typescript = {
							updateImportsOnPaste = true,
							suggest = {
								completeFunctionCalls = true,
							},
						},
					},
				},

				-- ── python ─────────────────────────────────────────────
				-- NOTE: the custom `cmd` pointed at
				-- `~/.local/bin/basedpyright-langserver`, which does not
				-- exist, so Python had no LSP at all. Let mason install
				-- it and use nvim-lspconfig's default command.
				basedpyright = {
					enabled = true,
					settings = {
						basedpyright = {
							analysis = {
								typeCheckingMode = "strict",
								diagnosticMode = "openFilesOnly",
								reportMissingTypeStubs = false,
								reportUnknownMemberAccess = false,
								reportUnknownVariableType = false,
								reportUnannotatedClassAttribute = false,
								autoImportCompletions = true,
								indexing = true,
							},
						},
					},
				},

				-- ── lua ───────────────────────────────────────────────
				lua_ls = {
					enabled = true,
					mason = false,
					on_attach = function(client, bufnr)
						client.server_capabilities.diagnosticProvider = false
						client.server_capabilities.documentSymbolProvider = true
						if vim.api.nvim_buf_line_count(bufnr) > 2000 then
							client.server_capabilities.semanticTokensProvider = nil
						end
					end,
					settings = {
						Lua = {
							runtime = { version = "LuaJIT" },
							diagnostics = {
								globals = { "vim" },
								disable = { "lowercase-global", "undefined-global", "missing-fields" },
								-- Delay workspace-wide recheck by 5s after the last change.
								workspaceDelay = 5000,
							},
							checkThirdParty = false,
							workspace = {
								checkThirdParty = false,
								library = { vim.env.VIMRUNTIME },
								ignoreDir = { "**/node_modules", "**/lazy", "**/.git", "**/packer_compiled.lua" },
								libraryStatus = "None",
								maxPreload = 2000,
								preloadFileSize = 5000,
							},
							telemetry = { enable = false },
						},
					},
				},

				-- ── c / c++ ───────────────────────────────────────────
				clangd = {
					enabled = true,
					mason = false,
					cmd = {
						"clangd",
						"--background-index",
						"--clang-tidy",
						"--query-driver=/usr/bin/g++,/usr/bin/gcc",
						"--fallback-style=google",
						"--pch-storage=memory",
						"--limit-references=0",
						"-j=4",
					},
					on_attach = function(client, bufnr)
						if vim.api.nvim_buf_line_count(bufnr) > 2000 then
							client.server_capabilities.semanticTokensProvider = nil
						end
						client.server_capabilities.documentFormattingProvider = false
					end,
				},

				-- ── assembly ───────────────────────────────────────────
				asm_lsp = {
					enabled = true,
					filetypes = { "asm", "s", "S", "nasm" },
					-- NOTE: since Neovim 0.11 `root_dir` is called with
					-- `(bufnr, callback)` and has to invoke the callback.
					-- A function that only *returns* the root leaves the
					-- client hanging and it never starts.
					root_dir = function(_, callback)
						callback(vim.fn.getcwd())
					end,
					settings = {
						["asm-lsp"] = {
							assembler = "nasm",
							instruction_set = "x86",
							default_diagnostics = false,
						},
					},
				},

				-- ── arduino ────────────────────────────────────────────
				arduino_language_server = {
					enabled = true,
					mason = false,
					cmd = {
						"arduino-language-server",
						"-clangd",
						"clangd",
						"-cli",
						"arduino-cli",
						"-cli-config",
						vim.fn.expand("~/.arduino15/arduino-cli.yaml"),
						"-fqbn",
						"arduino:avr:uno",
					},
				},

				-- ── c# / vb ────────────────────────────────────────────
				omnisharp = {
					enabled = true,
					filetypes = { "cs", "vb" },
					single_file_support = true,
					root_dir = function(bufnr, callback)
						local util = require("lspconfig.util")
						local root =
							util.root_pattern("*.sln", "*.csproj", "omnisharp.json")(vim.api.nvim_buf_get_name(bufnr))
						callback(root or vim.fn.getcwd())
					end,
					on_attach = function(client, bufnr)
						if client.server_capabilities.completionProvider then
							client.server_capabilities.completionProvider.triggerCharacters = { ".", ":" }
							client.server_capabilities.completionProvider.resolveProvider = true
						end
						client.server_capabilities.documentSymbolProvider = true
					end,
					settings = {
						FormattingOptions = {
							EnableEditorConfigSupport = false,
							OrganizeImports = false,
						},
						RoslynExtensionsOptions = {
							EnableAnalyzersSupport = false,
							EnableImportCompletion = true,
							AnalyzeOpenDocumentsOnly = true,
							EnableDecompilationSupport = false,
						},
						Sdk = { IncludePrereleases = false },
						msbuild = { loadProjectsOnDemand = true },
					},
				},

				-- ── glsl ───────────────────────────────────────────────
				glsl_analyzer = {
					enabled = true,
					filetypes = { "glsl", "vert", "tesc", "tese", "frag", "geom", "comp" },
					root_dir = function(_, callback)
						callback(vim.fn.getcwd())
					end,
					capabilities = {
						textDocument = {
							completion = {
								completionItem = {},
							},
							publishDiagnostics = {
								relatedInformation = true,
								tagSupport = { valueSet = { 1, 2 } },
							},
						},
					},
				},

				-- ── css / html ─────────────────────────────────────────
				cssls = {
					enabled = true,
					mason = false,
					filetypes = {
						"css",
						"scss",
						"less",
						"typescript",
						"typescriptreact",
						"javascript",
						"javascriptreact",
					},
					settings = {
						css = { validate = true },
						scss = { validate = true },
					},
					init_options = {
						provideFormatter = true,
					},
				},

				html = {
					enabled = true,
					mason = false,
					filetypes = { "html", "javascriptreact", "typescriptreact" },
					init_options = {
						configurationSection = { "html", "css", "javascript" },
						embeddedLanguages = {
							css = true,
							javascript = true,
						},
						provideFormatter = true,
					},
				},

				-- ── markdown ───────────────────────────────────────────
				marksman = {
					enabled = true,
					filetypes = { "markdown", "markdown.mdx" },
					root_dir = function(bufnr, callback)
						local util = require("lspconfig.util")
						local root =
							util.root_pattern(".git", ".marksman.toml", "README.md")(vim.api.nvim_buf_get_name(bufnr))
						callback(root or vim.fn.getcwd())
					end,
				},

				-- ── rust ───────────────────────────────────────────────
				-- rust-analyzer is *started* by rustaceanvim (see
				-- `lua/plugins/rustaceanvim.lua`), not by nvim-lspconfig.
				-- It still has to be listed here so that
				-- mason-lspconfig installs the binary, and the `setup`
				-- hook below keeps lspconfig from starting a second,
				-- conflicting client (rustaceanvim warns about exactly
				-- that).
				rust_analyzer = {
					enabled = true,
				},
			},

			-- `setup` is called for every server that nvim-lspconfig
			-- would otherwise set up. Returning `true` means "I take
			-- care of this server" and excludes it from
			-- mason-lspconfig's `automatic_enable`.
			setup = {
				rust_analyzer = function()
					return true
				end,
			},
		},
	},
	{
		"3rd/image.nvim",
		cond = function()
			return vim.env.KITTY_SCROLLBACK_NVIM ~= "true"
		end,
	},
}
