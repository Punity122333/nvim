local M = {}

local INDENT_WIDTH = require("config.indent_width").width

local function treesitter_indent()
  if _G.LazyVim and _G.LazyVim.treesitter and _G.LazyVim.treesitter.indentexpr then
    local ok, val = pcall(_G.LazyVim.treesitter.indentexpr)
    if ok and type(val) == "number" then
      return val
    end
  end
  local ok2, val2 = pcall(require("nvim-treesitter").indentexpr)
  if ok2 and type(val2) == "number" then
    return val2
  end
  return nil
end

function M.indentexpr()
  local lnum = vim.v.lnum
  if lnum == nil or lnum == 0 then
    return -1
  end

  local ts_indent = treesitter_indent()

  if ts_indent == nil or ts_indent < 0 then
    -- Treesitter bailed (no parser/query or error): pure cindent fallback.
    -- vim.fn.cindent() computes independently of the 'cindent' option.
    local ci = vim.fn.cindent(lnum)
    if ci ~= nil and ci >= 0 then
      return ci
    end
    return -1
  end

  -- Block-opener guard: a `...{` line must increase indent. Snippet
  -- placeholders (e.g. `if {} {`) can parse oddly and make treesitter
  -- return at or below the parent indent (e.g. parent 8 -> 6).
  if lnum > 1 then
    local prev = vim.fn.prevnonblank(lnum - 1)
    if prev > 0 then
      local bufnr = vim.api.nvim_get_current_buf()
      local ok, plines = pcall(vim.api.nvim_buf_get_lines, bufnr, prev - 1, prev, false)
      local ptext = (ok and plines and plines[1]) or ""
      ptext = ptext:gsub("%s+$", "")
      if ptext:sub(-1) == "{" then
        local pind = vim.fn.indent(prev)
        if ts_indent <= pind then
          local ci = vim.fn.cindent(lnum)
          if ci ~= nil and ci >= 0 then
            return ci
          end
          local sw = vim.fn.shiftwidth()
          if sw == 0 then
            sw = INDENT_WIDTH
          end
          return pind + sw
        end
      end
    end
  end

  return ts_indent
end

return M
