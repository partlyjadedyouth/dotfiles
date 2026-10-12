local sbar = require("sketchybar")
local settings = require("settings")
local colors = require("colors")
local strings = require("helpers.strings")
local config_dir = os.getenv("CONFIG_DIR") or (os.getenv("HOME") .. "/.config/sketchybar")

-- Open Vorssaint's native menu-bar panel through the existing menu helper.
local vorssaint = sbar.add("item", "widgets.vorssaint", {
  position = "right",
  width = 36,
  icon = { drawing = false },
  label = { drawing = false },
  background = {
    drawing = true,
    color = { alpha = 0 },
    border_width = 0,
    image = {
      string = config_dir .. "/assets/vorssaint.png",
      scale = 0.025,
      corner_radius = 0,
      border_width = 0,
    },
  },
})

local function open_menu()
  sbar.exec('"$CONFIG_DIR/helpers/menus/bin/menus" -s Vorssaint'
    .. " || open 'x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility'")
end

vorssaint:subscribe("mouse.clicked", function()
  sbar.exec("pgrep -x Vorssaint", function(result)
    if strings.trim(result) ~= "" then
      open_menu()
      return
    end

    sbar.exec("open -g -a Vorssaint", function()
      -- Give the newly launched app time to register its menu-bar item.
      sbar.delay(1, open_menu)
    end)
  end)
end)

sbar.add("bracket", "widgets.vorssaint.bracket", { vorssaint.name }, {
  background = { color = colors.bg1 },
})

sbar.add("item", "widgets.vorssaint.padding", {
  position = "right",
  width = settings.group_paddings,
})
