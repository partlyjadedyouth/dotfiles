local M = {}

function M.trim(value)
  if value == nil then
    return ""
  end
  return (value:gsub("^%s+", ""):gsub("%s+$", ""))
end

function M.shell_escape(value)
  return "'" .. value:gsub("'", [['\'']]) .. "'"
end

return M
