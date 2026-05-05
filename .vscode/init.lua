-- lua/snippet_engine/init.lua
-- Custom snippet engine: LSP snippet syntax, extmark sessions, mirroring,
-- regex transforms, choice UI, nested snippet history (session stack).
local M                    = {}
local ns                   = vim.api.nvim_create_namespace("snip_engine")

-- Localised API upvalues (avoid table-lookup overhead in hot paths)
local nvim_buf_get_extmark = vim.api.nvim_buf_get_extmark_by_id
local nvim_buf_get_lines   = vim.api.nvim_buf_get_lines
local nvim_buf_set_text    = vim.api.nvim_buf_set_text
local nvim_win_get_cursor  = vim.api.nvim_win_get_cursor
local nvim_win_set_cursor  = vim.api.nvim_win_set_cursor
local nvim_buf_set_extmark = vim.api.nvim_buf_set_extmark
local nvim_buf_clear_ns    = vim.api.nvim_buf_clear_namespace
local nvim_buf_del_extmark = vim.api.nvim_buf_del_extmark
local nvim_create_autocmd  = vim.api.nvim_create_autocmd
local nvim_del_augroup     = vim.api.nvim_del_augroup_by_id
local nvim_create_augroup  = vim.api.nvim_create_augroup
local nvim_open_win        = vim.api.nvim_open_win
local nvim_create_buf      = vim.api.nvim_create_buf
local nvim_buf_set_lines   = vim.api.nvim_buf_set_lines
local nvim_win_close       = vim.api.nvim_win_close
local nvim_buf_delete      = vim.api.nvim_buf_delete
local nvim_get_current_buf = vim.api.nvim_get_current_buf
local fn_matchlist         = vim.fn.matchlist
local fn_match             = vim.fn.match
local fn_mode              = vim.fn.mode
local fn_feedkeys          = vim.fn.feedkeys
local fn_maparg            = vim.fn.maparg
local tbl_concat           = table.concat
local str_split            = vim.split
local str_rep              = string.rep

-- Shared empty opts table — reused on every extmark query to avoid alloc
local EMPTY                = {}
local DETAILS              = { details = true }

-- ============================================================================
-- TRANSFORM HELPERS
-- ============================================================================

local modifiers            = {
    upcase     = function(s) return s:upper() end,
    downcase   = function(s) return s:lower() end,
    capitalize = function(s)
        if s == "" then return s end
        return s:sub(1, 1):upper() .. s:sub(2)
    end,
    camelcase  = function(s)
        local words, result = {}, nil
        for w in s:gmatch("[%w]+") do words[#words + 1] = w end
        if #words == 0 then return s end
        result = words[1]:lower()
        for i = 2, #words do
            result = result .. words[i]:sub(1, 1):upper() .. words[i]:sub(2):lower()
        end
        return result
    end,
    pascalcase = function(s)
        local result = ""
        for w in s:gmatch("[%w]+") do
            result = result .. w:sub(1, 1):upper() .. w:sub(2):lower()
        end
        return result
    end,
}

local BYTE                 = {
    BACKSLASH = 92,
    DOLLAR    = 36,
    LBRACE    = 123,
    RBRACE    = 125,
    COLON     = 58,
    PLUS      = 43,
    QUESTION  = 63,
    DASH      = 45,
    PIPE      = 124,
    COMMA     = 44,
    SLASH     = 47,
}

local function is_digit_byte(b)
    return b and b >= 48 and b <= 57
end

local function is_ident_byte(b)
    return b and (
        (b >= 48 and b <= 57) or
        (b >= 65 and b <= 90) or
        (b >= 97 and b <= 122) or
        b == 95
    )
end

local function parse_format(fmt)
    local segs = {}
    local i, len, text = 1, #fmt, ""
    local function flush()
        if text ~= "" then
            segs[#segs + 1] = { type = "lit", value = text }; text = ""
        end
    end
    while i <= len do
        local b = fmt:byte(i)
        if b == BYTE.BACKSLASH and i < len then
            i = i + 1
            text = text .. string.char(fmt:byte(i))
            i = i + 1
        elseif b == BYTE.DOLLAR then
            flush(); i = i + 1
            if fmt:byte(i) == BYTE.LBRACE then
                i = i + 1
                local s = i
                while i <= len and is_digit_byte(fmt:byte(i)) do i = i + 1 end
                local idx = tonumber(fmt:sub(s, i - 1)) or 0
                local nc  = fmt:byte(i)
                if nc == BYTE.RBRACE then
                    i = i + 1; segs[#segs + 1] = { type = "cap", index = idx }
                elseif nc == BYTE.COLON then
                    i = i + 1
                    local mc = fmt:byte(i)
                    if mc == BYTE.SLASH then
                        i = i + 1; local ms = i
                        while i <= len and fmt:byte(i) ~= BYTE.RBRACE do i = i + 1 end
                        local mod = fmt:sub(ms, i - 1)
                        if fmt:byte(i) == BYTE.RBRACE then i = i + 1 end
                        segs[#segs + 1] = { type = "cap", index = idx, modifier = mod }
                    elseif mc == BYTE.PLUS then
                        i = i + 1; local vs = i
                        while i <= len and fmt:byte(i) ~= BYTE.RBRACE do i = i + 1 end
                        local val = fmt:sub(vs, i - 1)
                        if fmt:byte(i) == BYTE.RBRACE then i = i + 1 end
                        segs[#segs + 1] = { type = "if_set", index = idx, value = val }
                    elseif mc == BYTE.QUESTION then
                        i = i + 1; local vs = i
                        while i <= len do
                            local bb = fmt:byte(i)
                            if bb == BYTE.COLON or bb == BYTE.RBRACE then break end
                            i = i + 1
                        end
                        local if_set = fmt:sub(vs, i - 1)
                        local if_not = ""
                        if fmt:byte(i) == BYTE.COLON then
                            i = i + 1; local vns = i
                            while i <= len and fmt:byte(i) ~= BYTE.RBRACE do i = i + 1 end
                            if_not = fmt:sub(vns, i - 1)
                        end
                        if fmt:byte(i) == BYTE.RBRACE then i = i + 1 end
                        segs[#segs + 1] = { type = "cond", index = idx, if_set = if_set, if_not = if_not }
                    elseif mc == BYTE.DASH then
                        i = i + 1; local ds = i
                        while i <= len and fmt:byte(i) ~= BYTE.RBRACE do i = i + 1 end
                        local def = fmt:sub(ds, i - 1)
                        if fmt:byte(i) == BYTE.RBRACE then i = i + 1 end
                        segs[#segs + 1] = { type = "default", index = idx, default = def }
                    else
                        while i <= len and fmt:byte(i) ~= BYTE.RBRACE do i = i + 1 end
                        if fmt:byte(i) == BYTE.RBRACE then i = i + 1 end
                        segs[#segs + 1] = { type = "cap", index = idx }
                    end
                else
                    if fmt:byte(i) == BYTE.RBRACE then i = i + 1 end
                    segs[#segs + 1] = { type = "cap", index = idx }
                end
            else
                local s = i
                while i <= len and is_digit_byte(fmt:byte(i)) do i = i + 1 end
                segs[#segs + 1] = { type = "cap", index = tonumber(fmt:sub(s, i - 1)) or 0 }
            end
        else
            text = text .. string.char(b); i = i + 1
        end
    end
    flush()
    return segs
end

local function apply_format(segs, captures)
    local parts = {}
    for _, seg in ipairs(segs) do
        if seg.type == "lit" then
            parts[#parts + 1] = seg.value
        elseif seg.type == "cap" then
            local val = captures[seg.index + 1] or ""
            if seg.modifier then
                local fn = modifiers[seg.modifier]; val = fn and fn(val) or val
            end
            parts[#parts + 1] = val
        elseif seg.type == "if_set" then
            if (captures[seg.index + 1] or "") ~= "" then parts[#parts + 1] = seg.value end
        elseif seg.type == "cond" then
            parts[#parts + 1] = (captures[seg.index + 1] or "") ~= "" and seg.if_set or seg.if_not
        elseif seg.type == "default" then
            local val = captures[seg.index + 1] or ""
            parts[#parts + 1] = val ~= "" and val or seg.default
        end
    end
    return tbl_concat(parts)
end

local function ecma_to_vim(p) return p:gsub("%(%?:", "%%(") end

local function apply_transform(src, regex, fmt_segs, flags)
    local pat = "\\v" .. ecma_to_vim(regex)
    if flags:find("i") then pat = "\\c" .. pat end
    local global = flags:find("g") ~= nil

    if not global then
        local caps = fn_matchlist(src, pat)
        if #caps == 0 then return src end
        local ms = fn_match(src, pat)
        local me = ms + #caps[1]
        return src:sub(1, ms) .. apply_format(fmt_segs, caps) .. src:sub(me + 1)
    end

    local result, rem = {}, src
    while rem ~= "" do
        local caps = fn_matchlist(rem, pat)
        if #caps == 0 then
            result[#result + 1] = rem; break
        end
        local ms = fn_match(rem, pat)
        local me = ms + #caps[1]
        result[#result + 1] = rem:sub(1, ms)
        result[#result + 1] = apply_format(fmt_segs, caps)
        rem = rem:sub(me + 1)
        if #caps[1] == 0 then
            if rem ~= "" then result[#result + 1] = rem:sub(1, 1) end
            rem = rem:sub(2)
        end
    end
    return tbl_concat(result)
end

-- ============================================================================
-- PARSER
-- ============================================================================

local VARS = {
    TM_FILENAME      = function() return vim.fn.expand("%:t") end,
    TM_FILENAME_BASE = function() return vim.fn.expand("%:t:r") end,
    TM_DIRECTORY     = function() return vim.fn.expand("%:p:h") end,
    TM_FILEPATH      = function() return vim.fn.expand("%:p") end,
    TM_LINE_NUMBER   = function() return tostring(vim.fn.line(".")) end,
    TM_CURRENT_LINE  = function() return vim.api.nvim_get_current_line() end,
    TM_CURRENT_WORD  = function() return vim.fn.expand("<cword>") end,
    CLIPBOARD        = function() return vim.fn.getreg("+") end,
    CURRENT_YEAR     = function() return os.date("%Y") end,
    CURRENT_MONTH    = function() return os.date("%m") end,
    CURRENT_DATE     = function() return os.date("%d") end,
}

local function parse(src)
    local pos, len = 1, #src
    local function peek() return src:byte(pos) end
    local function eat(n) pos = pos + (n or 1) end
    local function read_int()
        local s = pos
        while pos <= len and is_digit_byte(src:byte(pos)) do pos = pos + 1 end
        if pos == s then return nil end
        return tonumber(src:sub(s, pos - 1))
    end
    local function read_ident()
        local s = pos
        while pos <= len and is_ident_byte(src:byte(pos)) do pos = pos + 1 end
        if pos == s then return nil end
        return src:sub(s, pos - 1)
    end
    local function read_until(stop)
        local parts, s = {}, pos
        local stop_b = stop:byte()
        while pos <= len do
            local b = src:byte(pos)
            if b == BYTE.BACKSLASH and pos < len then
                parts[#parts + 1] = src:sub(s, pos - 1); pos = pos + 1
                parts[#parts + 1] = src:sub(pos, pos); pos = pos + 1; s = pos
            elseif b == stop_b then
                parts[#parts + 1] = src:sub(s, pos - 1); pos = pos + 1
                return tbl_concat(parts)
            else
                pos = pos + 1
            end
        end
        parts[#parts + 1] = src:sub(s, pos - 1)
        return tbl_concat(parts)
    end

    local parse_nodes
    local function parse_choice(index)
        local choices, cur = {}, ""
        while pos <= len do
            local b = peek()
            if b == BYTE.BACKSLASH and pos < len then
                eat(); cur = cur .. src:sub(pos, pos); eat()
            elseif b == BYTE.COMMA then
                choices[#choices + 1] = cur; cur = ""; eat()
            elseif b == BYTE.PIPE then
                choices[#choices + 1] = cur; eat()
                if peek() == BYTE.RBRACE then eat() end; break
            else
                cur = cur .. src:sub(pos, pos); eat()
            end
        end
        return { type = "choice", index = index, choices = choices }
    end

    parse_nodes = function(stop_char)
        local nodes, text = {}, ""
        local function flush()
            if text ~= "" then
                nodes[#nodes + 1] = { type = "text", value = text }; text = ""
            end
        end
        local stop_b = stop_char and stop_char:byte() or nil
        while pos <= len do
            local b = peek()
            if stop_b and b == stop_b then break end
            if b == BYTE.BACKSLASH and pos < len then
                eat(); text = text .. src:sub(pos, pos); eat()
            elseif b == BYTE.DOLLAR then
                flush(); eat()
                if peek() == BYTE.LBRACE then
                    eat()
                    local index = read_int()
                    if index then
                        local nc = peek()
                        if nc == BYTE.RBRACE then
                            eat(); nodes[#nodes + 1] = { type = "tabstop", index = index, children = {} }
                        elseif nc == BYTE.COLON then
                            eat()
                            local children = parse_nodes("}")
                            if peek() == BYTE.RBRACE then eat() end
                            nodes[#nodes + 1] = { type = "tabstop", index = index, children = children }
                        elseif nc == BYTE.PIPE then
                            eat(); nodes[#nodes + 1] = parse_choice(index)
                        elseif nc == BYTE.SLASH then
                            eat()
                            local regex       = read_until("/")
                            local format_raw  = read_until("/")
                            local flags       = read_until("}")
                            nodes[#nodes + 1] = {
                                type = "transform",
                                source = index,
                                regex = regex,
                                format_segs = parse_format(format_raw),
                                flags = flags,
                            }
                        else
                            local depth = 1
                            while pos <= len and depth > 0 do
                                local pb = peek()
                                if pb == BYTE.LBRACE then
                                    depth = depth + 1
                                elseif pb == BYTE.RBRACE then
                                    depth = depth - 1
                                end
                                eat()
                            end
                        end
                    else
                        local name = read_ident() or ""
                        local default_nodes = {}
                        if peek() == BYTE.COLON then
                            eat(); default_nodes = parse_nodes("}")
                        elseif peek() == BYTE.SLASH then
                            eat(); read_until("/"); read_until("/"); read_until("}"); goto var_done
                        end
                        if peek() == BYTE.RBRACE then eat() end
                        ::var_done::
                        local fn = VARS[name]
                        if fn then
                            nodes[#nodes + 1] = { type = "text", value = fn() }
                        elseif #default_nodes > 0 then
                            for _, n in ipairs(default_nodes) do nodes[#nodes + 1] = n end
                        end
                    end
                else
                    local index = read_int()
                    if index then
                        nodes[#nodes + 1] = { type = "tabstop", index = index, children = {} }
                    else
                        local name = read_ident() or ""
                        local fn = VARS[name]
                        if fn then nodes[#nodes + 1] = { type = "text", value = fn() } end
                    end
                end
            else
                text = text .. string.char(b); eat()
            end
        end
        flush()
        return nodes
    end
    return parse_nodes(nil)
end

-- ============================================================================
-- FLATTEN (two-phase, O(n))
-- ============================================================================

local function collect_defaults(nodes, defs)
    defs = defs or {}
    for _, node in ipairs(nodes) do
        if node.type == "tabstop" then
            if not defs[node.index] then
                local parts = {}
                local function text_of(nl)
                    for _, n in ipairs(nl) do
                        if n.type == "text" then
                            parts[#parts + 1] = n.value
                        elseif n.type == "choice" then
                            parts[#parts + 1] = (n.choices and n.choices[1]) or ""
                        elseif n.type == "tabstop" then
                            text_of(n.children or {})
                        end
                    end
                end
                text_of(node.children or {})
                defs[node.index] = tbl_concat(parts)
                collect_defaults(node.children or {}, defs)
            end
        elseif node.type == "choice" then
            if not defs[node.index] then
                defs[node.index] = (node.choices and node.choices[1]) or ""
            end
        end
    end
    return defs
end

local function flatten_nodes(nodes, base, out_ts, out_xf, defs)
    local parts  = {}
    local offset = base
    for _, node in ipairs(nodes) do
        if node.type == "text" then
            parts[#parts + 1] = node.value; offset = offset + #node.value
        elseif node.type == "tabstop" then
            local start       = offset
            local child_text  = flatten_nodes(node.children or {}, start, out_ts, out_xf, defs)
            parts[#parts + 1] = child_text; offset = offset + #child_text
            if not out_ts[node.index] then out_ts[node.index] = {} end
            out_ts[node.index][#out_ts[node.index] + 1] = { start = start, stop = offset, default = child_text }
        elseif node.type == "choice" then
            local start = offset
            local first = (node.choices and node.choices[1]) or ""
            parts[#parts + 1] = first; offset = offset + #first
            if not out_ts[node.index] then out_ts[node.index] = {} end
            out_ts[node.index][#out_ts[node.index] + 1] = {
                start = start,
                stop = offset,
                default = first,
                choices = node.choices
            }
        elseif node.type == "transform" then
            local result      = apply_transform(defs[node.source] or "", node.regex, node.format_segs, node.flags)
            local start       = offset
            parts[#parts + 1] = result; offset = offset + #result
            if not out_xf[node.source] then out_xf[node.source] = {} end
            out_xf[node.source][#out_xf[node.source] + 1] = {
                start = start, stop = offset, regex = node.regex, format_segs = node.format_segs, flags = node.flags,
            }
        end
    end
    return tbl_concat(parts)
end

local function flatten(nodes)
    local defs = collect_defaults(nodes)
    local out_ts, out_xf = {}, {}
    local text = flatten_nodes(nodes, 0, out_ts, out_xf, defs)
    return text, out_ts, out_xf
end

-- ============================================================================
-- POSITION MATH
-- ============================================================================

local function make_line_lens(lines)
    local lens, starts = {}, {}
    local offset = 0
    for i, l in ipairs(lines) do
        local len = #l
        lens[i] = len
        starts[i] = offset
        offset = offset + len + 1
    end
    return lens, starts
end

local function byte_to_rowcol(byte, line_starts, base_row, base_col)
    local lo, hi = 1, #line_starts
    local idx = 1
    while lo <= hi do
        local mid = math.floor((lo + hi) / 2)
        if line_starts[mid] <= byte then
            idx = mid
            lo = mid + 1
        else
            hi = mid - 1
        end
    end
    local cb = (idx == 1) and base_col or 0
    return base_row + idx - 1, cb + (byte - line_starts[idx])
end

-- ============================================================================
-- EXTMARK HELPERS
-- ============================================================================

local function mark_range(bufnr, id)
    local r = nvim_buf_get_extmark(bufnr, ns, id, DETAILS)
    if r and r[1] then
        local d = r[3] or EMPTY
        local er = d.end_row or r[1]
        local ec = d.end_col or r[2]
        return r[1], r[2], er, ec
    end
    return nil, nil, nil, nil
end

local function region_text(bufnr, id)
    local sr, sc, er, ec = mark_range(bufnr, id)
    if not sr then return "" end
    -- fast path: empty region
    if sr == er and sc == ec then return "" end
    local lines = nvim_buf_get_lines(bufnr, sr, er + 1, false)
    if #lines == 0 then return "" end
    if sr == er then return lines[1]:sub(sc + 1, ec) end
    lines[1]      = lines[1]:sub(sc + 1)
    lines[#lines] = lines[#lines]:sub(1, ec)
    return tbl_concat(lines, "\n")
end

local function set_region_text(bufnr, id, text)
    local sr, sc, er, ec = mark_range(bufnr, id)
    if not sr then return end
    -- fast path: no newlines → skip vim.split
    if text:find("\n", 1, true) then
        nvim_buf_set_text(bufnr, sr, sc, er, ec, str_split(text, "\n", { plain = true }))
    else
        nvim_buf_set_text(bufnr, sr, sc, er, ec, { text })
    end
end

-- ============================================================================
-- CHOICE UI
-- ============================================================================

local choice_state = nil

local function close_choice_ui()
    if not choice_state then return end
    for _, km in ipairs(choice_state.saved_maps) do
        if km.lhs then
            if km.callback then
                vim.keymap.set("i", km.lhs, km.callback, { buffer = km.buffer, silent = true })
            elseif km.rhs and km.rhs ~= "" then
                vim.keymap.set("i", km.lhs, km.rhs, { buffer = km.buffer, silent = true, expr = km.expr == 1 })
            else
                pcall(vim.keymap.del, "i", km.lhs, { buffer = km.buffer })
            end
        end
    end
    pcall(nvim_win_close, choice_state.win, true)
    pcall(nvim_buf_delete, choice_state.buf, { force = true })
    choice_state = nil
end

local function render_choice_float(buf, choices, selected)
    local lines = {}
    for i, ch in ipairs(choices) do
        lines[#lines + 1] = (i == selected and " ▶ " or "   ") .. ch
    end
    nvim_buf_set_lines(buf, 0, -1, false, lines)
    vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)
    vim.api.nvim_buf_add_highlight(buf, ns, "CursorLine", selected - 1, 0, -1)
end

local function open_choice_ui(bufnr, ts, sess)
    local choices = ts.choices
    if not choices or #choices == 0 then return end
    close_choice_ui()
    local selected = 1
    local max_w    = 4
    for _, ch in ipairs(choices) do max_w = math.max(max_w, #ch + 4) end

    local float_buf  = nvim_create_buf(false, true)
    local sr, sc     = mark_range(bufnr, ts.id)
    local win        = nvim_open_win(float_buf, false, {
        relative = "buf",
        buf = bufnr,
        bufpos = { sr, sc },
        row = 1,
        col = 0,
        width = max_w,
        height = #choices,
        style = "minimal",
        border = "rounded",
        focusable = false,
        zindex = 200,
    })
    vim.wo[win].wrap = false
    render_choice_float(float_buf, choices, selected)

    local function apply(idx)
        selected = idx
        render_choice_float(float_buf, choices, selected)
        local saved = nvim_win_get_cursor(0)
        sess._jumping = true
        set_region_text(bufnr, ts.id, choices[selected])
        local list = sess.tabstops[sess.current]
        if list then
            for i = 2, #list do set_region_text(bufnr, list[i].id, choices[selected]) end
        end
        sess._jumping = false
        pcall(nvim_win_set_cursor, 0, saved)
    end

    local intercept  = { "<C-n>", "<C-p>", "<CR>", "<Tab>", "<Esc>" }
    local saved_maps = {}
    for _, key in ipairs(intercept) do
        local m = fn_maparg(key, "i", false, true); m.buffer = bufnr
        saved_maps[#saved_maps + 1] = m
    end

    local o = { buffer = bufnr, silent = true, nowait = true }
    vim.keymap.set("i", "<C-n>", function() apply(selected < #choices and selected + 1 or 1) end, o)
    vim.keymap.set("i", "<C-p>", function() apply(selected > 1 and selected - 1 or #choices) end, o)
    vim.keymap.set("i", "<CR>", close_choice_ui, o)
    vim.keymap.set("i", "<Tab>", close_choice_ui, o)
    vim.keymap.set("i", "<Esc>", function()
        apply(1); close_choice_ui()
    end, o)

    choice_state = { win = win, buf = float_buf, saved_maps = saved_maps, bufnr = bufnr }
end

-- ============================================================================
-- SESSION STACK
-- A stack of sessions. Top of stack is the active session.
-- Expanding a snippet inside an active session pushes a new one.
-- Completing ($0) or destroying pops back to the parent.
-- ============================================================================

local stack = {} -- stack[#stack] = active session

local function top() return stack[#stack] end

local function clear_session_extmarks(sess)
    if not sess then return end
    if sess.tabstops then
        for _, ts_list in pairs(sess.tabstops) do
            for i = 1, #ts_list do
                local id = ts_list[i].id
                if id then pcall(nvim_buf_del_extmark, sess.bufnr, ns, id) end
            end
        end
    end
    if sess.transforms then
        for _, xf_list in pairs(sess.transforms) do
            for i = 1, #xf_list do
                local id = xf_list[i].id
                if id then pcall(nvim_buf_del_extmark, sess.bufnr, ns, id) end
            end
        end
    end
end

-- Pop the top session off the stack, clean up its resources.
-- Does NOT resume the parent — caller decides whether to resume.
local function pop_session()
    local sess = stack[#stack]
    if not sess then return end
    close_choice_ui()
    pcall(nvim_del_augroup, sess.aug)
    clear_session_extmarks(sess)
    stack[#stack] = nil
end

-- Destroy the entire stack (e.g. BufLeave)
local function destroy_stack()
    close_choice_ui()
    for i = #stack, 1, -1 do
        pcall(nvim_del_augroup, stack[i].aug)
        pcall(nvim_buf_clear_ns, stack[i].bufnr, ns, 0, -1)
        stack[i] = nil
    end
end

local function sort_indices(ts)
    local idxs = {}
    for k in pairs(ts) do idxs[#idxs + 1] = k end
    table.sort(idxs, function(a, b)
        if a == 0 then return false end
        if b == 0 then return true end
        return a < b
    end)
    return idxs
end

local function update_transforms(sess, index)
    local xf_list = sess.transforms[index]
    if not xf_list or #xf_list == 0 then return end
    local ts_list = sess.tabstops[index]
    if not ts_list or #ts_list == 0 then return end
    local src     = region_text(sess.bufnr, ts_list[1].id)
    local saved   = nvim_win_get_cursor(0)
    sess._jumping = true
    for _, xf in ipairs(xf_list) do
        set_region_text(sess.bufnr, xf.id,
            apply_transform(src, xf.regex, xf.format_segs, xf.flags))
    end
    sess._jumping = false
    pcall(nvim_win_set_cursor, 0, saved)
end

local function select_tabstop(bufnr, ts)
    local sr, sc, er, ec = mark_range(bufnr, ts.id)
    if not sr then return end
    if sr == er and sc == ec then
        nvim_win_set_cursor(0, { sr + 1, sc })
        if fn_mode() ~= "i" then vim.cmd("startinsert") end
        return
    end
    if sr == er then
        nvim_win_set_cursor(0, { sr + 1, sc })
        local ctrl_g = vim.api.nvim_replace_termcodes("<C-G>", true, false, true)
        fn_feedkeys("v" .. (ec - sc > 1 and str_rep("l", ec - sc - 1) or "") .. ctrl_g, "n")
    else
        nvim_win_set_cursor(0, { sr + 1, sc })
        if fn_mode() ~= "i" then vim.cmd("startinsert") end
    end
end

-- Resume a paused session (used when popping back to parent)
local function resume_session(sess)
    if not sess then return end
    local ts_list = sess.tabstops[sess.current]
    if not ts_list or #ts_list == 0 then return end
    local ts = ts_list[1]
    sess._jumping = true
    if ts.choices then
        local sr, sc = mark_range(sess.bufnr, ts.id)
        if sr then
            nvim_win_set_cursor(0, { sr + 1, sc })
            if fn_mode() ~= "i" then vim.cmd("startinsert") end
        end
        open_choice_ui(sess.bufnr, ts, sess)
    else
        select_tabstop(sess.bufnr, ts)
    end
    vim.schedule(function() if top() == sess then sess._jumping = false end end)
end

local function activate(sess, index)
    close_choice_ui()
    if sess.current ~= nil then update_transforms(sess, sess.current) end
    local ts_list = sess.tabstops[index]
    if not ts_list or #ts_list == 0 then return end
    sess.current      = index

    -- Cache primary mark ID and mirror presence for hot TextChangedI path
    sess._pri_id      = ts_list[1].id
    sess._has_mirrors = #ts_list > 1

    sess._jumping     = true
    local ts          = ts_list[1]
    if ts.choices then
        local sr, sc = mark_range(sess.bufnr, ts.id)
        if sr then
            nvim_win_set_cursor(0, { sr + 1, sc })
            if fn_mode() ~= "i" then vim.cmd("startinsert") end
        end
        open_choice_ui(sess.bufnr, ts, sess)
    else
        select_tabstop(sess.bufnr, ts)
    end
    vim.schedule(function() if top() == sess then sess._jumping = false end end)
end

-- ============================================================================
-- EXPAND
-- ============================================================================

function M.expand(snippet_body)
    if type(snippet_body) == "table" then
        snippet_body = tbl_concat(snippet_body, "\n")
    end

    -- Suspend the parent session immediately so that any InsertLeave fired
    -- during blink's completion flow (before this expand fully runs) does not
    -- pop the parent off the stack. resume_session() will clear _jumping when
    -- the child finishes.
    local parent = top()
    if parent then parent._jumping = true end

    local ast                    = parse(snippet_body)
    local text, out_ts, out_xf   = flatten(ast)
    local lines                  = str_split(text, "\n", { plain = true })
    local line_lens, line_starts = make_line_lens(lines)
    local cur                    = nvim_win_get_cursor(0)
    local row0, col0             = cur[1] - 1, cur[2]

    local bufnr                  = nvim_get_current_buf()

    -- Single atomic buffer write
    nvim_buf_set_text(bufnr, row0, col0, row0, col0, lines)

    local sess_ts = {}
    for index, occurrences in pairs(out_ts) do
        sess_ts[index] = {}
        for _, occ in ipairs(occurrences) do
            local sr, sc = byte_to_rowcol(occ.start, line_starts, row0, col0)
            local er, ec = byte_to_rowcol(occ.stop, line_starts, row0, col0)
            local id = nvim_buf_set_extmark(bufnr, ns, sr, sc, {
                right_gravity = false,
                end_row = er,
                end_col = ec,
                end_right_gravity = true,
                virt_text = EMPTY,
            })
            sess_ts[index][#sess_ts[index] + 1] = { id = id, choices = occ.choices }
        end
    end

    local sess_xf = {}
    for source, xfs in pairs(out_xf) do
        sess_xf[source] = {}
        for _, xf in ipairs(xfs) do
            local sr, sc = byte_to_rowcol(xf.start, line_starts, row0, col0)
            local er, ec = byte_to_rowcol(xf.stop, line_starts, row0, col0)
            local id = nvim_buf_set_extmark(bufnr, ns, sr, sc, {
                right_gravity = false,
                end_row = er,
                end_col = ec,
                end_right_gravity = true,
                virt_text = EMPTY,
            })
            sess_xf[source][#sess_xf[source] + 1] = {
                id = id,
                regex = xf.regex,
                format_segs = xf.format_segs,
                flags = xf.flags,
            }
        end
    end

    if not sess_ts[0] then
        local er   = row0 + #lines - 1
        local ec   = (#lines == 1 and col0 or 0) + line_lens[#line_lens]
        local id   = nvim_buf_set_extmark(bufnr, ns, er, ec, {
            right_gravity = false,
            end_row = er,
            end_col = ec,
            end_right_gravity = true,
            virt_text = EMPTY,
        })
        sess_ts[0] = { { id = id } }
    end

    local indices = sort_indices(sess_ts)

    local sess = {
        bufnr        = bufnr,
        tabstops     = sess_ts,
        transforms   = sess_xf,
        indices      = indices,
        current      = nil,
        _jumping     = false,
        _pri_id      = nil,   -- primary mark ID of current tabstop (hot path cache)
        _has_mirrors = false, -- precomputed: current tabstop has >1 occurrence
        aug          = nvim_create_augroup("SnipEngine" .. tostring(#stack + 1), { clear = true }),
    }

    -- Mirror handler: fires on every keypress while inside a tabstop.
    -- All expensive checks are ordered cheapest-first.
    nvim_create_autocmd("TextChangedI", {
        group    = sess.aug,
        buffer   = bufnr,
        callback = function()
            -- Only handle if this session is the active top of stack
            if top() ~= sess then return end
            if sess._jumping then return end
            if not sess._has_mirrors then return end
            if choice_state then return end

            local c              = nvim_win_get_cursor(0)
            local crow, ccol     = c[1] - 1, c[2]
            local sr, sc, er, ec = mark_range(bufnr, sess._pri_id)
            if not sr then return end

            if not ((crow > sr or (crow == sr and ccol >= sc))
                    and (crow < er or (crow == er and ccol <= ec))) then
                return
            end

            local new_text = region_text(bufnr, sess._pri_id)
            local saved    = nvim_win_get_cursor(0)
            sess._jumping  = true
            local list     = sess.tabstops[sess.current]
            for i = 2, #list do
                set_region_text(bufnr, list[i].id, new_text)
            end
            sess._jumping = false
            pcall(nvim_win_set_cursor, 0, saved)
        end,
    })

    -- InsertLeave: pop only the current session, resume parent if any.
    -- BufLeave: destroy everything.
    nvim_create_autocmd("InsertLeave", {
        group    = sess.aug,
        buffer   = bufnr,
        callback = function()
            if top() ~= sess then return end
            if sess._jumping then return end
            -- Don't pop if we're transitioning to visual/select mode — this happens
            -- when select_tabstop uses feedkeys("v...ctrl_g") to select a placeholder.
            -- vim.schedule resets _jumping BEFORE the typehead 'v' is processed, so
            -- _jumping is already false by the time this InsertLeave fires from 'v'.
            -- Checking the destination mode here is the correct guard.
            local m = fn_mode()
            if m == "v" or m == "V" or m == "s" or m == "S"
                or m == "\22" or m == "\19" then
                return
            end
            pop_session()
            local parent = top()
            if parent then resume_session(parent) end
        end,
    })

    nvim_create_autocmd("BufLeave", {
        group    = sess.aug,
        buffer   = bufnr,
        callback = function()
            destroy_stack()
        end,
    })

    -- Push onto stack and activate first tabstop
    stack[#stack + 1] = sess
    activate(sess, indices[1])
end

-- ============================================================================
-- JUMP API
-- ============================================================================

function M.active(direction)
    local sess = top()
    if not sess then return false end
    for i, idx in ipairs(sess.indices) do
        if idx == sess.current then
            return direction > 0 and i < #sess.indices or i > 1
        end
    end
    return false
end

function M.jump(direction)
    local sess = top()
    if not sess then return false end
    local next_i = nil
    for i, idx in ipairs(sess.indices) do
        if idx == sess.current then
            next_i = i + (direction > 0 and 1 or -1); break
        end
    end
    if not next_i or next_i < 1 or next_i > #sess.indices then return false end
    local next_idx = sess.indices[next_i]
    activate(sess, next_idx)
    if next_idx == 0 then
        vim.schedule(function()
            pop_session()
            local parent = top()
            if parent then resume_session(parent) end
        end)
    end
    return true
end

function M.get_session() return top() end

function M.destroy() destroy_stack() end

return M
