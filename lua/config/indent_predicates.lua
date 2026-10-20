local M = {}

function M.setup()
  local ts = vim.treesitter
  if not ts or not ts.query or not ts.query.add_predicate then
    return
  end
  pcall(ts.query.add_predicate, "not-kind-eq?", function(match, _, _, pred)
    local nodes = match[pred[2]]
    if not nodes or #nodes == 0 then
      return true
    end
    local types = { unpack(pred, 3) }
    for _, node in ipairs(nodes) do
      if vim.list_contains(types, node:type()) then
        return false
      end
    end
    return true
  end, { force = true })
end

return M
