-- lua/config/numbers.lua
--
-- Single owner of the line-number options.
--
-- 'number' and 'relativenumber' are global-local options.  `init_sc` (see
-- `lua/config/options.lua`) hides them in the special buffers (dap,
-- avante, the snacks pickers, ...), which means it also has to set them
-- explicitly in the normal buffers - and that is exactly where a plain
-- `vim.wo.relativenumber = x` toggle gets lost: the toggle sets the value
-- of the current window, and the next `BufEnter` overwrites it again.
--
-- So the *global* value is the one that is toggled, and `sync()` copies it
-- into the windows.
local M = {}

--- Read a global option.
---@param name string
---@return boolean
local function global(name)
	return vim.api.nvim_get_option_value(name, { scope = "global" })
end

--- Copy the global line-number options into the current window.
---
--- The global value is read with `scope = "global"` on purpose:
--- `vim.opt.<name>:get()` returns the *effective* (local) value, which is
--- the thing that is being overwritten here.
function M.sync()
	vim.opt_local.number = global("number")
	vim.opt_local.relativenumber = global("relativenumber")
end

--- Flip the global "relative numbers" option and apply it to every window.
---@return boolean relativenumber the new value
function M.toggle()
	local rn = not global("relativenumber")
	vim.api.nvim_set_option_value("relativenumber", rn, { scope = "global" })
	for _, win in ipairs(vim.api.nvim_list_wins()) do
		pcall(vim.api.nvim_win_call, win, M.sync)
	end
	return rn
end

return M
