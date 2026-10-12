local sbar = require("sketchybar")
local colors = require("colors")
local icons = require("icons")
local settings = require("settings")
local workspaces = require("helpers.workspaces")
local strings = require("helpers.strings")
local trim = strings.trim
local shell_escape = strings.shell_escape

local spaces = {}
local space_brackets = {}
local space_paddings = {}
local workspace_order = {}
local workspace_gap = 5
local refresh_running = false
local refresh_queued = false
local queued_focused_workspace = nil
local focused_workspace = nil
local workspace_monitors = {}

local function set_workspace_items(workspace, properties)
  for _, collection in ipairs({ spaces, space_brackets, space_paddings }) do
    local item = collection[workspace]
    if item then item:set(properties) end
  end
end

local function reorder_aux_items(callback)
  local moves = {}
  local anchor_name = "apple.logo"

  for _, workspace in ipairs(workspace_order) do
    for _, item in ipairs({ spaces[workspace], space_paddings[workspace] }) do
      moves[#moves + 1] = "--move " .. shell_escape(item.name)
        .. " after " .. shell_escape(anchor_name)
      anchor_name = item.name
    end
  end

  -- Move the entire workspace row in one request before revealing newly added items.
  -- Inserting after apple.logo keeps every workspace before spaces.indicator.
  if #moves > 0 then
    sbar.exec("sketchybar " .. table.concat(moves, " ") .. " >/dev/null 2>&1", callback)
  elseif callback then
    callback()
  end
end

local function set_focused_space(workspace)
  local focused = trim(workspace)
  if focused == "" then
    return
  end
  focused_workspace = focused

  for _, workspace in ipairs(workspace_order) do
    local selected = workspace == focused
    if spaces[workspace] ~= nil then
      spaces[workspace]:set({
        icon = { highlight = selected },
        label = { highlight = selected },
        background = { border_color = selected and colors.black or colors.bg2 }
      })
    end
    if space_brackets[workspace] ~= nil then
      space_brackets[workspace]:set({
        background = { border_color = selected and colors.grey or colors.bg2 }
      })
    end
  end
end

local function update_focused_space(workspace, callback)
  local focused = trim(workspace)
  if focused ~= "" then
    set_focused_space(focused)
    if callback then callback() end
    return
  end

  sbar.exec("aerospace list-workspaces --focused 2>/dev/null | head -n 1", function(result)
    set_focused_space(result)
    if callback then callback() end
  end)
end

local function remove_space(workspace)
  if spaces[workspace] ~= nil then
    sbar.remove(spaces[workspace].name)
    spaces[workspace] = nil
  end
  if space_brackets[workspace] ~= nil then
    sbar.remove(space_brackets[workspace].name)
    space_brackets[workspace] = nil
  end
  if space_paddings[workspace] ~= nil then
    sbar.remove(space_paddings[workspace].name)
    space_paddings[workspace] = nil
  end
end

local function create_space(workspace)
  local key = workspaces.key(workspace)
  local space_name = "space." .. key
  local padding_name = "space.padding." .. key
  local bracket_name = "space.bracket." .. key

  local space = sbar.add("item", space_name, {
    drawing = false,
    icon = {
      font = { family = settings.font.numbers, size = 12.0 },
      string = workspace,
      padding_left = 8,
      padding_right = 8,
      color = colors.white,
      highlight_color = colors.red,
    },
    label = {
      drawing = false,
      padding_left = 0,
      padding_right = 8,
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

  local space_bracket = sbar.add("bracket", bracket_name, { space.name }, {
    drawing = false,
    background = {
      color = colors.transparent,
      border_color = colors.bg2,
      height = 28,
      border_width = 2
    }
  })

  local space_padding = sbar.add("item", padding_name, {
    drawing = false,
    script = "",
    width = workspace_gap,
  })

  spaces[workspace] = space
  space_brackets[workspace] = space_bracket
  space_paddings[workspace] = space_padding

  local escaped_workspace = shell_escape(workspace)
  space:subscribe("mouse.clicked", function(env)
    if env.BUTTON == "right" then
      sbar.exec(
        "aerospace move-node-to-workspace --focus-follows-window "
          .. escaped_workspace .. " >/dev/null 2>&1",
        function()
          update_focused_space(workspace)
        end
      )
    else
      sbar.exec("aerospace workspace " .. escaped_workspace .. " >/dev/null 2>&1", function()
        update_focused_space(workspace)
      end)
    end
  end)
end

local function sync_workspaces(callback)
  sbar.exec("aerospace list-workspaces --all --format '%{workspace}\t%{monitor-appkit-nsscreen-screens-id}' 2>/dev/null", function(result)
    local ordered, seen, monitor_by_workspace = workspaces.parse_workspaces(result)
    local structure_changed = false

    workspace_monitors = monitor_by_workspace

    for workspace, _ in pairs(spaces) do
      if not seen[workspace] then
        remove_space(workspace)
        structure_changed = true
      end
    end

    for _, workspace in ipairs(ordered) do
      if spaces[workspace] == nil then
        create_space(workspace)
        structure_changed = true
      end

      local monitor = monitor_by_workspace[workspace]
      if monitor ~= nil and monitor ~= "" then
        set_workspace_items(workspace, { display = monitor })
      end
    end

    if not workspaces.same_order(workspace_order, ordered) then
      structure_changed = true
    end
    workspace_order = ordered
    if structure_changed then
      reorder_aux_items(callback)
    elseif callback then
      callback()
    end
  end)
end

local function fit_workspaces(apps_by_space, callback)
  sbar.exec("sketchybar --query front_app", function(front_app)
    -- The existing menu toggle hides front_app together with the workspace row.
    if type(front_app) == "table" and front_app.geometry
      and front_app.geometry.drawing == "off"
    then
      if callback then callback() end
      return
    end
    -- Start with every name visible. Only empty, unfocused spaces may be hidden.
    for _, workspace in ipairs(workspace_order) do
      set_workspace_items(workspace, { drawing = true })
    end

    sbar.exec("aerospace list-monitors --format '%{monitor-appkit-nsscreen-screens-id} %{monitor-name}'", function(monitors)
      local built_in = {}
      for line in tostring(monitors):gmatch("[^\r\n]+") do
        local id, name = line:match("^(%d+)%s+(.+)$")
        if name and name:lower():find("built%-in") then
          built_in[id] = true
        end
      end

      sbar.exec("sketchybar --query displays", function(displays)
        if type(displays) == "table" then
          for _, display in ipairs(displays) do
            local id = tostring(display["arrangement-id"])
            if built_in[id] then
              local rect_key = "display-" .. id
              local widths = {}
              local total, start = 0, nil
              for _, workspace in ipairs(workspace_order) do
                if workspace_monitors[workspace] == id then
                  local info = spaces[workspace]:query()
                  local rect = info.bounding_rects and info.bounding_rects[rect_key]
                  if rect then
                    local width = rect.size[1] + workspace_gap
                      + info.geometry.padding_left + info.geometry.padding_right
                    widths[workspace] = width
                    total = total + width
                    start = math.min(start or rect.origin[1], rect.origin[1])
                  end
                end
              end
              local front_rect = type(front_app) == "table" and front_app.bounding_rects
                and front_app.bounding_rects[rect_key]
              -- Reserve the notch's default 200-point width, the spaces toggle,
              -- the current app name, and a small safety margin.
              local available = (display.frame.w - 200) / 2 - (start or 0)
                - 40 - (front_rect and front_rect.size[1] or 0)
              for i = #workspace_order, 1, -1 do
                local workspace = workspace_order[i]
                if total > available and widths[workspace]
                  and workspace ~= focused_workspace and #apps_by_space[workspace] == 0
                then
                  set_workspace_items(workspace, { drawing = false })
                  total = total - widths[workspace]
                end
              end
            end
          end
        end
        if callback then callback() end
      end)
    end)
  end)
end

local function update_windows_on_spaces(callback)
  sbar.exec("aerospace list-windows --all --format '%{workspace}\t%{app-name}' 2>/dev/null", function(result)
    local apps_by_space = workspaces.parse_windows(result, spaces)

    for _, workspace in ipairs(workspace_order) do
      local space = spaces[workspace]
      if space ~= nil then
        space:set({ label = {
          string = workspaces.icon_line(apps_by_space[workspace]),
          drawing = #apps_by_space[workspace] > 0,
        } })
      end
    end

    fit_workspaces(apps_by_space, callback)
  end)
end

local function run_refresh(focused_workspace)
  refresh_running = true
  sync_workspaces(function()
    update_focused_space(focused_workspace, function()
      update_windows_on_spaces(function()
        refresh_running = false

        if refresh_queued then
          local queued = queued_focused_workspace
          refresh_queued = false
          queued_focused_workspace = nil
          sbar.exec("true", function()
            run_refresh(queued)
          end)
        end
      end)
    end)
  end)
end

local function refresh_spaces(focused_workspace)
  local focused = trim(focused_workspace)
  if focused == "" then
    focused = nil
  end

  if refresh_running then
    refresh_queued = true
    if focused ~= nil then
      queued_focused_workspace = focused
    end
    return
  end

  run_refresh(focused)
end

sbar.add("event", "aerospace_workspace_change")
sbar.add("event", "windows_on_spaces")
sbar.add("event", "window_focus")

local space_window_observer = sbar.add("item", {
  drawing = false,
  updates = true,
  update_freq = 5,
})

local spaces_indicator = sbar.add("item", "spaces.indicator", {
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

space_window_observer:subscribe("aerospace_workspace_change", function(env)
  refresh_spaces(env and env.FOCUSED or nil)
end)

space_window_observer:subscribe({
  "windows_on_spaces",
  "front_app_switched",
  "window_focus",
  "routine",
  "display_change",
  "swap_menus_and_spaces",
}, function()
  refresh_spaces()
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

refresh_spaces()
