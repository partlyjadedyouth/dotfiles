-- Upstream mapping (helpers/icon_map.lua) with personal overrides applied.
-- Refresh the upstream half with ./helpers/update_app_font.sh; put your own
-- entries in helpers/app_icons_overrides.lua.
local icons = {}

for app, icon in pairs(require("helpers.icon_map")) do
	icons[app] = icon
end

for app, icon in pairs(require("helpers.app_icons_overrides")) do
	icons[app] = icon
end

return icons
