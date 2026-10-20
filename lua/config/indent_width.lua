local M = {
	width = 2,
	column_width = 120,
}

---@param buf? integer
---@return integer
function M.shiftwidth(buf)
	local sw = buf and vim.bo[buf].shiftwidth or vim.bo.shiftwidth
	if sw == nil or sw == 0 then
		sw = M.width
	end
	return sw
end

return M
