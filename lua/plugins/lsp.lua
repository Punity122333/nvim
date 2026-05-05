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
		opts = {
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
				vtsls = {
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
				basedpyright = {
					mason = false,
					cmd = { "/home/pxnity/.local/bin/basedpyright-langserver", "--stdio" },
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
				marksman = {
					filetypes = { "markdown", "markdown.mdx" },
					root_dir = function(fname)
						local util = require("lspconfig.util")
						return util.root_pattern(".git", ".marksman.toml", "README.md")(fname) or vim.fn.getcwd()
					end,
				},
				asm_lsp = {
					cmd = { "asm-lsp" },
					filetypes = { "asm", "s", "S", "nasm" },
					root_dir = function()
						return vim.fn.getcwd()
					end,
					settings = {
						["asm-lsp"] = {
							assembler = "nasm",
							instruction_set = "x86",
							default_diagnostics = false,
						},
					},
					on_attach = function(client, bufnr)
						client.server_capabilities.diagnosticProvider = false
						vim.diagnostic.enable(false, { bufnr = bufnr })
					end,
				},
				clangd = {
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

				lua_ls = {
					on_attach = function(client, bufnr)
						client.server_capabilities.diagnosticProvider = false
						client.server_capabilities.documentSymbolProvider = true
					end,
					settings = {
						Lua = {
							runtime = { version = "LuaJIT" },
							diagnostics = {
								globals = { "vim" },
								disable = { "lowercase-global", "undefined-global", "missing-fields" },
								-- Delay workspace-wide recheck by 3s after last change.
								-- Prevents spam-publishing diagnostics for every file on each keystroke.
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
				omnisharp = {
					cmd = {
						"omnisharp",
						"--languageserver",
						"--hostPID",
						tostring(vim.fn.getpid()),
					},
					filetypes = { "cs", "vb" },
					single_file_support = true,
					root_dir = function(fname)
						local util = require("lspconfig.util")
						local root = util.root_pattern("*.sln", "*.csproj", "omnisharp.json")(fname)
						if not root then
							local dir = vim.fn.fnamemodify(fname, ":h")
							local dir_name = vim.fn.fnamemodify(dir, ":t")
							local csproj_path = dir .. "/" .. dir_name .. ".csproj"
							if vim.fn.filereadable(csproj_path) == 0 then
								local csproj_content = [[<Project Sdk="Microsoft.NET.Sdk">
                                            <PropertyGroup>
                                                <OutputType>Exe</OutputType>
                                                <TargetFramework>net8.0</TargetFramework>
                                                <ImplicitUsings>enable</ImplicitUsings>
                                                <Nullable>enable</Nullable>
                                            </PropertyGroup>
                                            </Project>]]
								local file = io.open(csproj_path, "w")
								if file then
									file:write(csproj_content)
									file:close()
								end
							end
							return dir
						end
						return root
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
				glsl_analyzer = {
					cmd = { "glsl_analyzer" },
					filetypes = { "glsl", "vert", "tesc", "tese", "frag", "geom", "comp" },
					root_dir = function(fname)
						return vim.fn.getcwd()
					end,
					on_attach = function(client, bufnr)
						vim.diagnostic.enable(true, { bufnr = bufnr })
					end,
				},
				cssls = {
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

				pasls = {
					mason = false,
					cmd = { vim.fn.expand("~/.local/bin/pasls") },
					filetypes = { "pascal" },
					root_dir = function(fname)
						local util = require("lspconfig.util")
						return util.root_pattern("*.lpi", "*.lpr", "*.dpr", ".git")(fname) or vim.fn.getcwd()
					end,
					settings = {
					},
				},
			},
		},
		config = function(_, opts)
			vim.diagnostic.config(opts.diagnostics)

			-- Allowing basedpyright and clangd to keep their tokens
			vim.api.nvim_create_autocmd("LspAttach", {
				callback = function(args)
					local client = vim.lsp.get_client_by_id(args.data.client_id)
					if client then
						client.server_capabilities.semanticTokensProvider = nil
					end
				end,
			})

			local orig = vim.lsp.handlers["textDocument/publishDiagnostics"]
			local lua_ls_ids = {}
			local lua_ls_cfg = opts.servers.lua_ls
			local lua_ls_upstream_attach = lua_ls_cfg.on_attach
			lua_ls_cfg.on_attach = function(client, bufnr)
				lua_ls_ids[client.id] = true
				if lua_ls_upstream_attach then
					lua_ls_upstream_attach(client, bufnr)
				end
			end

			-- Single global timer for lua_ls: collapses the entire workspace
			-- diagnostic flood (N buffers) into one callback 800ms after the
			-- last push, instead of N independent per-buffer timers staggered
			-- across the workspace.
			local lua_ls_timer = nil
			local timers = {}

			vim.lsp.handlers["textDocument/publishDiagnostics"] = function(err, result, ctx, cfg)
				if lua_ls_ids[ctx.client_id] then
					if lua_ls_timer then
						lua_ls_timer:stop()
						lua_ls_timer:close()
					end
					lua_ls_timer = vim.defer_fn(function()
						lua_ls_timer = nil
						orig(err, result, ctx, cfg)
					end, 800)
					return
				end

				-- Non-lua_ls servers keep per-buffer debounce
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

			local ok, lspconfig = pcall(require, "lspconfig")
			if not ok then
				return
			end

			local default_capabilities = vim.lsp.protocol.make_client_capabilities()
			default_capabilities.general = default_capabilities.general or {}
			default_capabilities.general.positionEncodings = { "utf-8" }

			local skip_servers = {
				copilot = true,
				stylua = true,
				tsserver = true,
				ts_ls = true,
				ruff = true,
				ruff_lsp = true,
				rust_analyzer = true,
				r_language_server = true,
				tsgo = true,
				oxfmt = true,
				["*"] = true,
			}

			for server_name, server_config in pairs(opts.servers) do
				if not skip_servers[server_name] and lspconfig[server_name] then
					local config = vim.deepcopy(server_config)
					config.capabilities =
						vim.tbl_deep_extend("force", {}, default_capabilities, config.capabilities or {})

					config.offsetEncoding = "utf-8"

					if
						config.capabilities.textDocument
						and config.capabilities.textDocument.completion
						and config.capabilities.textDocument.completion.completionItem
					then
						config.capabilities.textDocument.completion.completionItem.snippetSupport = true
					end

					lspconfig[server_name].setup(config)
				end
			end
		end,
	},
	{
		"3rd/image.nvim",
		cond = function()
			return vim.env.KITTY_SCROLLBACK_NVIM ~= "true"
		end,
	},
}
