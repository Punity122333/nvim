local project = require "lazyvim.plugins.extras.util.project"
return {
	"saghen/blink.cmp",
	dependencies = { "rafamadriz/friendly-snippets" },
	lazy = false,

	opts = function(_, opts)
		local _engine = nil
		local function engine()
			if not _engine then
				_engine = require("snippet_engine")
			end
			return _engine
		end

		local _ts_capable = {}
		local function buf_has_ts()
			local bufnr = vim.api.nvim_get_current_buf()
			local cached = _ts_capable[bufnr]
			if cached ~= nil then
				return cached
			end
			local ok = pcall(vim.treesitter.get_parser, bufnr)
			_ts_capable[bufnr] = ok
			if ok then
				vim.api.nvim_buf_attach(bufnr, false, {
					on_detach = function()
						_ts_capable[bufnr] = nil
					end,
				})
			end
			return ok
		end

		local function get_paren_state(line, col)
			local c = line:sub(col, col)
			if c == "" then
				return nil
			end
			local b = c:byte()
			if not (b == 95 or b == 46 or (b >= 48 and b <= 57) or (b >= 65 and b <= 90) or (b >= 97 and b <= 122)) then
				return nil
			end

			local next = line:sub(col + 1, col + 1)
			if next ~= "(" then
				return nil
			end

			if line:sub(col + 2, col + 2) == ")" then
				return "empty"
			end

			return "open"
		end

		local function has_closing_paren_ts(row, col)
			if not buf_has_ts() then
				return false
			end

			local node = vim.treesitter.get_node({ pos = { row - 1, col } })
			if not node then
				return false
			end

			local depth = 0
			while node and depth < 50 do
				local t = node:type()
				if t == "call_expression" or t == "function_call" then
					local _, _, er, ec = node:range()
					if er > (row - 1) or ec > col then
						return true
					end
					local ln = vim.api.nvim_buf_get_lines(0, er, er + 1, false)[1]
					return ln ~= nil and ln:sub(ec, ec) == ")"
				end
				node = node:parent()
				depth = depth + 1
			end

			return false
		end

		local _paren_ctx = nil
		local _callable_kinds = nil
		local function callable_kinds()
			if not _callable_kinds then
				local kinds = vim.lsp.protocol.CompletionItemKind
				_callable_kinds = {
					[kinds.Function] = true,
					[kinds.Method] = true,
					[kinds.Constructor] = true,
				}
			end
			return _callable_kinds
		end

		local _snippet_format = nil
		local function snippet_format()
			if not _snippet_format then
				_snippet_format = vim.lsp.protocol.InsertTextFormat.Snippet
			end
			return _snippet_format
		end

		local function smart_accept(cmp)
			if not cmp.is_visible() then
				return false
			end

			local pos = vim.api.nvim_win_get_cursor(0)
			local line = vim.api.nvim_get_current_line()

			_paren_ctx = get_paren_state(line, pos[2])

			local ok = cmp.accept()
			if not ok then
				_paren_ctx = nil
				return false
			end

			vim.schedule(function()
				local state = _paren_ctx
				_paren_ctx = nil

				if not state then
					return
				end

				local pos2 = vim.api.nvim_win_get_cursor(0)
				local row2, col2 = pos2[1], pos2[2]
				local line2 = vim.api.nvim_get_current_line()

				local did_insert = false
				local did_move = false

				if state == "open" then
					local has_close = line2:find(")", col2 + 1, true) ~= nil
					if not has_close then
						has_close = has_closing_paren_ts(row2, col2)
					end
					if not has_close then
						vim.api.nvim_buf_set_text(0, row2 - 1, col2, row2 - 1, col2, { ")" })
						line2 = vim.api.nvim_get_current_line()
						did_insert = true
					end
				end

				local open = line2:find("(", col2 + 1, true)
				if open then
					vim.api.nvim_win_set_cursor(0, { row2, open })
					did_move = true
				end

				if did_insert or did_move then
					local final = vim.api.nvim_win_get_cursor(0)
					if final[2] > 0 then
						vim.api.nvim_win_set_cursor(0, { final[1], final[2] - 1 })
					end
				end
			end)

			return true
		end

		local _emoji_kind = nil
		local function emoji_kind()
			if not _emoji_kind then
				_emoji_kind = require("blink.cmp.types").CompletionItemKind.Text
			end
			return _emoji_kind
		end

		local function strip_call_parens(item, field)
			if field == "insertText" then
				if item.insertText then
					item.insertText = item.insertText:gsub("%b()", "", 1)
				end
				return
			end

			if field == "textEdit" then
				local te = item.textEdit
				if te and te.newText then
					te.newText = te.newText:gsub("%b()", "", 1)
				end
				return
			end

			local it = item.insertText
			if it and it:find("(", 1, true) then
				item.insertText = it:gsub("%b()", "", 1)
			end

			local te = item.textEdit
			if te then
				local nt = te.newText
				if nt and nt:find("(", 1, true) then
					te.newText = nt:gsub("%b()", "", 1)
				end
			end
		end

		return vim.tbl_deep_extend("force", opts or {}, {
			enabled = function()
				return vim.b.blink_enabled ~= false and vim.bo.buftype ~= "prompt"
			end,

			snippets = {
				preset = "default",
				expand = function(snippet)
					engine().expand(snippet)
				end,
			},

			completion = {
				list = {
					selection = { preselect = true, auto_insert = false },
				},
				ghost_text = { enabled = false },
				trigger = {
					show_on_keyword = true,
					show_on_trigger_character = true,
				},
				accept = {
					auto_brackets = { enabled = false },
					resolve_timeout_ms = 100,
					dot_repeat = false,
				},
				menu = {
					auto_show = true,
					border = "rounded",
					scrollbar = false,
					winhighlight = "Normal:BlinkCmpMenu,FloatBorder:BlinkCmpMenuBorder,CursorLine:BlinkCmpMenuSelection,Search:None",
				},
				documentation = {
					auto_show = true,
          auto_show_delay_ms = 500,
          update_delay_ms = 300,
					window = {
						scrollbar = false,
						border = "rounded",
						winhighlight = "Normal:BlinkCmpDoc,FloatBorder:BlinkCmpDocBorder,CursorLine:BlinkCmpDocCursorLine",
					},
				},
			},

			signature = { enabled = false },

			fuzzy = {
				implementation = "prefer_rust_with_warning",
			},

			keymap = {
				preset = "default",

				["<Up>"] = { "fallback" },
				["<Down>"] = { "fallback" },
				["<C-n>"] = { "select_next", "fallback" },
				["<A-n>"] = { "select_next", "fallback" },
				["<C-p>"] = { "select_prev", "fallback" },
				["<A-p>"] = { "select_prev", "fallback" },
				["<C-Up>"] = { "select_prev", "fallback" },
				["<C-Down>"] = { "select_next", "fallback" },
				["<C-j>"] = { "select_next", "fallback" },
				["<C-k>"] = { "select_prev", "fallback" },

				["<S-CR>"] = { smart_accept, "fallback" },
				["<A-CR>"] = { smart_accept, "fallback" },
				["<C-y>"] = { smart_accept, "fallback" },
				["<C-CR>"] = { smart_accept, "fallback" },

				["<C-S-0>"] = {
					function()
						vim.lsp.buf.signature_help()
						return true
					end,
					"fallback",
				},
				["<C-]>"] = {
					function()
						vim.lsp.buf.signature_help()
						return true
					end,
					"fallback",
				},

				["<Tab>"] = {
					function()
						local e = engine()
						if e.active(1) then
							e.jump(1)
							return true
						end
						return false
					end,
					"snippet_forward",
					"fallback",
				},

				["<S-Tab>"] = {
					function()
						local e = engine()
						if e.active(-1) then
							e.jump(-1)
							return true
						end
						return false
					end,
					"snippet_backward",
					"fallback",
				},
			},

			sources = {
				default = { "snippets", "lsp", "path", "buffer" },
				providers = {
					lsp = {
						name = "lsp",
						enabled = true,
						module = "blink.cmp.sources.lsp",
						max_items = 25,
						timeout_ms = 1000,

						transform_items = function(ctx, items)
							local count = #items
							if count == 0 then
								return items
							end

							local format = snippet_format()
							local kinds = callable_kinds()
							local candidates = nil

							for i = 1, count do
								local item = items[i]
								local kind = item.kind
								if kind and kinds[kind] and item.insertTextFormat == format then
									local it = item.insertText
									if it and it:find("(", 1, true) then
										candidates = candidates or {}
										candidates[#candidates + 1] = { item = item, field = "insertText" }
									else
										local te = item.textEdit
										local nt = te and te.newText
										if nt and nt:find("(", 1, true) then
											candidates = candidates or {}
											candidates[#candidates + 1] = { item = item, field = "textEdit" }
										end
									end
								end
							end

							if not candidates then
								return items
							end

							local pos = vim.api.nvim_win_get_cursor(0)
							local line = vim.api.nvim_get_current_line()
							local state = get_paren_state(line, pos[2])
							if not state then
								return items
							end

							for i = 1, #candidates do
								local candidate = candidates[i]
								strip_call_parens(candidate.item, candidate.field)
							end

							return items
						end,
					},

					buffer = { max_items = 25 },
					path = { max_items = 25 },

					snippets = {
						name = "snippets",
						enabled = true,
						max_items = 8,
						min_keyword_length = 2,
						module = "blink.cmp.sources.snippets",
						opts = {
							friendly_snippets = true,
							search_paths = {
								vim.fn.expand("~/.config/nvim/snippets"),
							},
						},
					},

					emoji = {
						name = "emoji",
						module = "blink.compat.source",
						transform_items = function(ctx, items)
							local kind = emoji_kind()
							for i = 1, #items do
								items[i].kind = kind
							end
							return items
						end,
					},
				},
			},
		})
	end,
}
