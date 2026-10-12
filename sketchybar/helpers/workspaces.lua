local app_icons = require("helpers.app_icons")
local trim = require("helpers.strings").trim
local M = {}

function M.key(workspace)
  local bytes = {}
  for i = 1, #workspace, 1 do
    bytes[#bytes + 1] = string.format("%02x", workspace:byte(i))
  end
  return table.concat(bytes)
end

function M.same_order(left, right)
  if #left ~= #right then
    return false
  end

  for i = 1, #left, 1 do
    if left[i] ~= right[i] then
      return false
    end
  end

  return true
end

function M.icon_line(apps)
  if apps == nil or #apps == 0 then
    return ""
  end

  local icon_line = {}
  for _, app in ipairs(apps) do
    local lookup = app_icons[app]
    local icon = (lookup == nil) and app_icons["Default"] or lookup
    icon_line[#icon_line + 1] = icon
  end
  return table.concat(icon_line)
end

-- AeroSpace emits tab-separated fields; keep parsing independent of bar updates.
function M.parse_workspaces(result)
  local seen, ordered, monitors = {}, {}, {}
  for line in result:gmatch("[^\r\n]+") do
    local workspace, monitor = line:match("^([^\t]+)\t(.+)$")
    workspace, monitor = trim(workspace), trim(monitor)
    if workspace ~= "" then
      if not seen[workspace] then
        seen[workspace] = true
        ordered[#ordered + 1] = workspace
      end
      monitors[workspace] = monitor
    end
  end
  return ordered, seen, monitors
end

function M.parse_windows(result, spaces)
  local apps, seen = {}, {}
  for workspace in pairs(spaces) do
    apps[workspace], seen[workspace] = {}, {}
  end
  for line in result:gmatch("[^\r\n]+") do
    local workspace, app = line:match("^([^\t]+)\t(.+)$")
    workspace, app = trim(workspace), trim(app)
    if apps[workspace] and app ~= "" and not seen[workspace][app] then
      apps[workspace][#apps[workspace] + 1] = app
      seen[workspace][app] = true
    end
  end
  return apps
end

return M
