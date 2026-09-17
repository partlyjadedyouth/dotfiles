-- Personal overrides layered on top of the generated helpers/icon_map.lua.
-- This is the only icon mapping file meant to be hand-edited.
return {
	-- Not mapped upstream
	["ATLAS.ti"] = ":apple_books:",

	-- Prefer the generic glyph over the app-specific one upstream picked
	["Cursor"] = ":code:",
	["Skim"] = ":pdf:",
	["zathura"] = ":pdf:",
	["预览"] = ":pdf:",
	["Aperçu"] = ":pdf:",
}
