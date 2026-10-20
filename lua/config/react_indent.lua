local M = {}
local INDENT_WIDTH = require("config.indent_width").width
local function fallback()
  if _G.LazyVim and _G.LazyVim.treesitter then
    local ok, val = pcall(_G.LazyVim.treesitter.indentexpr)
    if ok and type(val) == "number" then
      return val
    end
  end
  local ok2, val2 = pcall(require("nvim-treesitter").indentexpr)
  if ok2 and type(val2) == "number" then
    return val2
  end
  return -1
end
local function smallest(bufnr, row, col)
  local ok, parser = pcall(vim.treesitter.get_parser, bufnr)
  if not ok or parser == nil then
    return nil, nil
  end
  local ok2, lang, root = pcall(function()
    local best_lang = nil
    local best_root = nil
    local best_size = nil
    parser:for_each_tree(function(tstree, tree)
      local l = tree:lang()
      if l == "comment" or l == "luadoc" or l == "javadoc" or l == "jsdoc" then
        return
      end
      local r = tstree:root()
      if r and vim.treesitter.is_in_node_range(r, row, col) then
        local size = r:byte_length()
        if best_size == nil or size < best_size then
          best_size = size
          best_lang = l
          best_root = r
        end
      end
    end)
    return best_lang, best_root
  end)
  if not ok2 then
    return nil, nil
  end
  return lang, root
end
function M.indentexpr()
  local bufnr = vim.api.nvim_get_current_buf()
  local lnum = vim.v.lnum
  if lnum == nil or lnum == 0 then
    return fallback()
  end
  local ft = vim.bo[bufnr].filetype
  if ft ~= "typescriptreact" and ft ~= "javascriptreact" and ft ~= "typescript" and ft ~= "javascript" then
    return fallback()
  end
  local line = vim.api.nvim_buf_get_lines(bufnr, lnum - 1, lnum, false)[1]
  if line == nil then
    return fallback()
  end
  local lang, root
  if line:find("^%s*$") then
    lang, root = smallest(bufnr, lnum - 1, 0)
  else
    local _, indentcols = line:find("^%s*")
    if indentcols == nil then
      indentcols = 0
    end
    lang, root = smallest(bufnr, lnum - 1, indentcols)
  end
  if root == nil then
    return fallback()
  end
  if lang == "html" then
    local srow_h, scol_h = root:range()
    if lnum - (srow_h + 1) > 120 then
      return fallback()
    end
    local sw_h = vim.bo[bufnr].shiftwidth
    if sw_h == 0 then
      sw_h = INDENT_WIDTH
    end
    local outer_h = vim.fn.indent(srow_h + 1)
    local inner_h = outer_h + sw_h
    local cur_h = line:gsub("^%s+", "")
    if cur_h:sub(1, 1) == "`" then
      return outer_h
    end
    local depth_h = 0
    local interp_h = 0
    local r_h = srow_h + 1
    while r_h < lnum do
      local text_h = vim.api.nvim_buf_get_lines(bufnr, r_h - 1, r_h, false)[1] or ""
      if r_h == srow_h + 1 then
        local cut_h = scol_h + 2
        if cut_h > 1 and cut_h <= #text_h + 1 then
          text_h = text_h:sub(cut_h)
        end
      end
      local i_h = 1
      local n_h = #text_h
      local in_s_h = false
      local in_d_h = false
      while i_h <= n_h do
        local c_h = text_h:sub(i_h, i_h)
        local d_h = text_h:sub(i_h + 1, i_h + 1)
        if in_s_h then
          if c_h == "\\" then
            i_h = i_h + 2
          elseif c_h == "'" then
            in_s_h = false
            i_h = i_h + 1
          else
            i_h = i_h + 1
          end
        elseif in_d_h then
          if c_h == "\\" then
            i_h = i_h + 2
          elseif c_h == '"' then
            in_d_h = false
            i_h = i_h + 1
          else
            i_h = i_h + 1
          end
        elseif interp_h > 0 then
          if c_h == "{" then
            interp_h = interp_h + 1
            i_h = i_h + 1
          elseif c_h == "}" then
            interp_h = interp_h - 1
            i_h = i_h + 1
          else
            i_h = i_h + 1
          end
        else
          if c_h == "'" then
            in_s_h = true
            i_h = i_h + 1
          elseif c_h == '"' then
            in_d_h = true
            i_h = i_h + 1
          elseif c_h == "$" and d_h == "{" then
            interp_h = 1
            i_h = i_h + 2
          elseif c_h == "<" then
            local j_h = i_h + 1
            local q_h = nil
            while j_h <= n_h do
              local e_h = text_h:sub(j_h, j_h)
              if q_h then
                if e_h == "\\" then
                  j_h = j_h + 2
                elseif e_h == q_h then
                  q_h = nil
                  j_h = j_h + 1
                else
                  j_h = j_h + 1
                end
              else
                if e_h == "'" or e_h == '"' then
                  q_h = e_h
                  j_h = j_h + 1
                elseif e_h == ">" then
                  break
                else
                  j_h = j_h + 1
                end
              end
            end
            if j_h > n_h then
              i_h = n_h + 1
            else
              local tag_h = text_h:sub(i_h + 1, j_h - 1)
              local first_h = tag_h:sub(1, 1)
              local last_h = tag_h:sub(-1)
              if first_h == "/" then
                depth_h = depth_h - 1
                if depth_h < 0 then
                  depth_h = 0
                end
              elseif first_h ~= "!" and first_h ~= "?" and last_h ~= "/" then
                local name_h = tag_h:match("^%s*([%w]+)")
                if name_h then
                  name_h = name_h:lower()
                  if name_h ~= "br" and name_h ~= "hr" and name_h ~= "img" and name_h ~= "input" and name_h ~= "meta" and name_h ~= "link" and name_h ~= "source" and name_h ~= "wbr" and name_h ~= "area" and name_h ~= "base" and name_h ~= "col" and name_h ~= "embed" and name_h ~= "track" and name_h ~= "param" then
                    depth_h = depth_h + 1
                  end
                end
              end
              i_h = j_h + 1
            end
          else
            i_h = i_h + 1
          end
        end
      end
      r_h = r_h + 1
    end
    if cur_h:sub(1, 2) == "</" then
      local v_h = inner_h + (depth_h - 1) * sw_h
      if v_h < outer_h then
        v_h = outer_h
      end
      return v_h
    end
    return inner_h + depth_h * sw_h
  end
  if lang ~= "scss" and lang ~= "css" then
    return fallback()
  end
  local srow, scol = root:range()
  if lnum - (srow + 1) > 120 then
    return fallback()
  end
  local sw = vim.bo[bufnr].shiftwidth
  if sw == 0 then
    sw = INDENT_WIDTH
  end
  local outer = vim.fn.indent(srow + 1)
  local inner = outer + sw
  local cur_trim = line:gsub("^%s+", "")
  if cur_trim:sub(1, 1) == "`" then
    return outer
  end
  local depth = 0
  local in_block = false
  local interp = 0
  local r = srow + 1
  while r < lnum do
    local text = vim.api.nvim_buf_get_lines(bufnr, r - 1, r, false)[1] or ""
    if r == srow + 1 then
      local cut = scol + 2
      if cut > 1 and cut <= #text + 1 then
        text = text:sub(cut)
      end
    end
    local i = 1
    local n = #text
    local in_single = false
    local in_double = false
    while i <= n do
      local c = text:sub(i, i)
      local d = text:sub(i + 1, i + 1)
      if in_block then
        if c == "*" and d == "/" then
          in_block = false
          i = i + 2
        else
          i = i + 1
        end
      elseif in_single then
        if c == "\\" then
          i = i + 2
        elseif c == "'" then
          in_single = false
          i = i + 1
        else
          i = i + 1
        end
      elseif in_double then
        if c == "\\" then
          i = i + 2
        elseif c == '"' then
          in_double = false
          i = i + 1
        else
          i = i + 1
        end
      elseif interp > 0 then
        if c == "{" then
          interp = interp + 1
          i = i + 1
        elseif c == "}" then
          interp = interp - 1
          i = i + 1
        else
          i = i + 1
        end
      else
        if c == "/" and d == "*" then
          in_block = true
          i = i + 2
        elseif c == "/" and d == "/" then
          break
        elseif c == "'" then
          in_single = true
          i = i + 1
        elseif c == '"' then
          in_double = true
          i = i + 1
        elseif c == "$" and d == "{" then
          interp = 1
          i = i + 2
        elseif c == "{" then
          depth = depth + 1
          i = i + 1
        elseif c == "}" then
          depth = depth - 1
          if depth < 0 then
            depth = 0
          end
          i = i + 1
        else
          i = i + 1
        end
      end
    end
    r = r + 1
  end
  if cur_trim:sub(1, 1) == "}" then
    local v = inner + (depth - 1) * sw
    if v < outer then
      v = outer
    end
    return v
  end
  return inner + depth * sw
end
function M.setup()
  local group = vim.api.nvim_create_augroup("ReactIndent", { clear = true })
  vim.api.nvim_create_autocmd("FileType", {
    group = group,
    pattern = { "javascript", "typescript", "javascriptreact", "typescriptreact" },
    callback = function(args)
      local b = args.buf
      vim.schedule(function()
        if vim.api.nvim_buf_is_valid(b) then
          vim.bo[b].indentexpr = "v:lua.require'config.react_indent'.indentexpr()"
        end
      end)
    end,
  })
  for _, b in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_valid(b) then
      local ok, f = pcall(function()
        return vim.bo[b].filetype
      end)
      if ok and (f == "javascript" or f == "typescript" or f == "javascriptreact" or f == "typescriptreact") then
        vim.bo[b].indentexpr = "v:lua.require'config.react_indent'.indentexpr()"
      end
    end
  end
end
return M
