#!/usr/bin/env bash
# Updates sketchybar-app-font. Fetches the .ttf and the generated icon_map.lua
# from the same release, since new glyphs only exist in the matching font file.
#
# Usage: ./update_app_font.sh [tag]   (defaults to the latest release)
set -euo pipefail

repo="kvndrsslr/sketchybar-app-font"
helpers_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
font_dir="$HOME/Library/Fonts"
tag="${1:-}"

if [ -z "$tag" ]; then
	tag="$(curl -fsSL "https://api.github.com/repos/$repo/releases/latest" |
		sed -n 's/.*"tag_name": *"\([^"]*\)".*/\1/p')"
fi
[ -n "$tag" ] || { echo "could not resolve a release tag" >&2; exit 1; }

current="$(cat "$helpers_dir/icon_map.version" 2>/dev/null || true)"
if [ "$tag" = "$current" ]; then
	echo "already on $tag"
	exit 0
fi

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

base="https://github.com/$repo/releases/download/$tag"
curl -fsSL -o "$tmp/icon_map.lua" "$base/icon_map.lua"
curl -fsSL -o "$tmp/sketchybar-app-font.ttf" "$base/sketchybar-app-font.ttf"

# Refuse to install a map that is not the table items/spaces.lua expects.
lua -e 'local m = dofile("'"$tmp"'/icon_map.lua")
	assert(type(m) == "table", "icon_map.lua is not a table")
	assert(m["Default"], "icon_map.lua has no Default entry")
	print(("%d entries"):format(#(function() local n = {} for k in pairs(m) do n[#n+1] = k end return n end)()))'

mkdir -p "$font_dir"
mv "$tmp/icon_map.lua" "$helpers_dir/icon_map.lua"
mv "$tmp/sketchybar-app-font.ttf" "$font_dir/sketchybar-app-font.ttf"
printf '%s\n' "$tag" >"$helpers_dir/icon_map.version"

echo "sketchybar-app-font updated${current:+ from $current} to $tag"

# Report overrides that upstream now covers identically - safe to delete.
lua -e 'package.path = "'"$helpers_dir"'/../?.lua;" .. package.path
	local up = dofile("'"$helpers_dir"'/icon_map.lua")
	for app, icon in pairs(dofile("'"$helpers_dir"'/app_icons_overrides.lua")) do
		if up[app] == icon then
			print(("override for %q is now redundant"):format(app))
		end
	end'

sketchybar --reload >/dev/null 2>&1 || true
