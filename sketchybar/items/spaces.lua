local colors = require("colors")
local icons = require("icons")
local settings = require("settings")
local app_icons = require("helpers.app_icons")

local max_spaces = 5
local spaces = {}
local space_brackets = {}
local space_paddings = {}

local function trim(value)
  if value == nil then
    return ""
  end
  return (value:gsub("^%s+", ""):gsub("%s+$", ""))
end

local function build_icon_line(apps)
  if apps == nil or #apps == 0 then
    return " —"
  end

  local icon_line = ""
  for _, app in ipairs(apps) do
    local lookup = app_icons[app]
    local icon = (lookup == nil) and app_icons["Default"] or lookup
    icon_line = icon_line .. icon
  end
  return icon_line
end

local function set_focused_space(focused_workspace)
  local focused = trim(focused_workspace)
  if focused == "" then
    return
  end

  for i = 1, max_spaces, 1 do
    local selected = tostring(i) == focused
    spaces[i]:set({
      icon = { highlight = selected },
      label = { highlight = selected },
      background = { border_color = selected and colors.black or colors.bg2 }
    })
    space_brackets[i]:set({
      background = { border_color = selected and colors.grey or colors.bg2 }
    })
  end
end

local function update_focused_space(focused_workspace)
  local focused = trim(focused_workspace)
  if focused ~= "" then
    set_focused_space(focused)
    return
  end

  sbar.exec("aerospace list-workspaces --focused 2>/dev/null | head -n 1", function(result)
    set_focused_space(result)
  end)
end

local function update_windows_on_spaces()
  sbar.exec("aerospace list-windows --all --format '%{workspace}|%{app-name}' 2>/dev/null", function(result)
    local apps_by_space = {}
    local seen_by_space = {}
    for i = 1, max_spaces, 1 do
      local sid = tostring(i)
      apps_by_space[sid] = {}
      seen_by_space[sid] = {}
    end

    for line in string.gmatch(result, "[^\r\n]+") do
      local workspace, app = line:match("^(.-)|(.+)$")
      workspace = trim(workspace)
      app = trim(app)
      if apps_by_space[workspace] ~= nil and app ~= "" and not seen_by_space[workspace][app] then
        table.insert(apps_by_space[workspace], app)
        seen_by_space[workspace][app] = true
      end
    end

    sbar.animate("tanh", 10, function()
      for i = 1, max_spaces, 1 do
        local sid = tostring(i)
        spaces[i]:set({ label = build_icon_line(apps_by_space[sid]) })
      end
    end)
  end)
end

local function update_space_displays()
  sbar.exec("aerospace list-workspaces --all --format '%{workspace}|%{monitor-id}' 2>/dev/null", function(result)
    local monitor_by_space = {}
    for line in string.gmatch(result, "[^\r\n]+") do
      local workspace, monitor = line:match("^(.-)|(.+)$")
      workspace = trim(workspace)
      monitor = trim(monitor)
      if workspace ~= "" and monitor ~= "" then
        monitor_by_space[workspace] = monitor
      end
    end

    for i = 1, max_spaces, 1 do
      local sid = tostring(i)
      local monitor = monitor_by_space[sid]
      if monitor ~= nil then
        spaces[i]:set({ display = monitor })
        space_brackets[i]:set({ display = monitor })
        space_paddings[i]:set({ display = monitor })
      end
    end
  end)
end

sbar.add("event", "aerospace_workspace_change")
sbar.add("event", "windows_on_spaces")
sbar.add("event", "window_focus")

for i = 1, max_spaces, 1 do
  local sid = tostring(i)
  local space = sbar.add("item", "space." .. sid, {
    icon = {
      font = { family = settings.font.numbers },
      string = i,
      padding_left = 15,
      padding_right = 8,
      color = colors.white,
      highlight_color = colors.red,
    },
    label = {
      padding_right = 20,
      color = colors.grey,
      highlight_color = colors.white,
      font = "sketchybar-app-font:Regular:16.0",
      y_offset = -1,
    },
    padding_right = 1,
    padding_left = 1,
    background = {
      color = colors.bg1,
      border_width = 1,
      height = 26,
      border_color = colors.black,
    },
  })

  spaces[i] = space

  -- Single item bracket for space items to achieve double border on highlight
  local space_bracket = sbar.add("bracket", { space.name }, {
    background = {
      color = colors.transparent,
      border_color = colors.bg2,
      height = 28,
      border_width = 2
    }
  })
  space_brackets[i] = space_bracket

  -- Padding space
  local space_padding = sbar.add("item", "space.padding." .. sid, {
    script = "",
    width = settings.group_paddings,
  })
  space_paddings[i] = space_padding

  space:subscribe("mouse.clicked", function(env)
    if env.BUTTON == "right" then
      sbar.exec("aerospace move-node-to-workspace --focus-follows-window " .. sid .. " >/dev/null 2>&1", function()
        update_focused_space(sid)
        update_windows_on_spaces()
      end)
    else
      sbar.exec("aerospace workspace " .. sid .. " >/dev/null 2>&1", function()
        update_focused_space(sid)
        update_windows_on_spaces()
      end)
    end
  end)
end

local space_focus_observer = sbar.add("item", {
  drawing = false,
  updates = true,
})

local space_window_observer = sbar.add("item", {
  drawing = false,
  updates = true,
  update_freq = 5,
})

local spaces_indicator = sbar.add("item", {
  padding_left = -3,
  padding_right = 0,
  icon = {
    padding_left = 8,
    padding_right = 9,
    color = colors.grey,
    string = icons.switch.on,
  },
  label = {
    width = 0,
    padding_left = 0,
    padding_right = 8,
    string = "Spaces",
    color = colors.bg1,
  },
  background = {
    color = colors.with_alpha(colors.grey, 0.0),
    border_color = colors.with_alpha(colors.bg1, 0.0),
  }
})

space_focus_observer:subscribe("aerospace_workspace_change", function(env)
  update_focused_space(env and env.FOCUSED or nil)
  update_space_displays()
end)

space_window_observer:subscribe("aerospace_workspace_change", function(env)
  update_windows_on_spaces()
end)

space_window_observer:subscribe("windows_on_spaces", update_windows_on_spaces)
space_window_observer:subscribe("front_app_switched", update_windows_on_spaces)
space_window_observer:subscribe("window_focus", update_windows_on_spaces)
space_window_observer:subscribe("routine", function(env)
  update_space_displays()
  update_windows_on_spaces()
end)

spaces_indicator:subscribe("swap_menus_and_spaces", function(env)
  local currently_on = spaces_indicator:query().icon.value == icons.switch.on
  spaces_indicator:set({
    icon = currently_on and icons.switch.off or icons.switch.on
  })
end)

spaces_indicator:subscribe("mouse.entered", function(env)
  sbar.animate("tanh", 30, function()
    spaces_indicator:set({
      background = {
        color = { alpha = 1.0 },
        border_color = { alpha = 1.0 },
      },
      icon = { color = colors.bg1 },
      label = { width = "dynamic" }
    })
  end)
end)

spaces_indicator:subscribe("mouse.exited", function(env)
  sbar.animate("tanh", 30, function()
    spaces_indicator:set({
      background = {
        color = { alpha = 0.0 },
        border_color = { alpha = 0.0 },
      },
      icon = { color = colors.grey },
      label = { width = 0, }
    })
  end)
end)

spaces_indicator:subscribe("mouse.clicked", function(env)
  sbar.trigger("swap_menus_and_spaces")
end)

update_focused_space()
update_space_displays()
update_windows_on_spaces()
