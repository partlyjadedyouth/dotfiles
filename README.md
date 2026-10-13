# Dotfiles

Personal macOS dotfiles for a development setup built around AeroSpace, SketchyBar, Zsh, and Vim.

This repo is a working collection of personal tweaks, borrowed ideas, and refinements collected over time.

## What Is Included

- `git/`: global Git config and ignore rules
- `zsh/`: `oh-my-zsh` shell setup with `powerlevel10k`, aliases, and language/toolchain bootstrapping
- `vim/`: a small `.vimrc` that layers on top of `amix/vimrc`
- `aerospace/`: AeroSpace tiling window manager config and keybindings
- `sketchybar/`: Lua-based SketchyBar setup with workspace, app, and system widgets
- `borders/`: JankyBorders config for active window borders
- `ghostty/`: Ghostty terminal config (theme and fonts)

## Platform Assumptions

These dotfiles are intended for macOS and assume Apple Silicon-style Homebrew paths such as `/opt/homebrew/...`.

Some configs also assume these tools are installed:

- [Homebrew](https://brew.sh/)
- [AeroSpace](https://github.com/nikitabobko/AeroSpace)
- [SketchyBar](https://felixkratz.github.io/SketchyBar/)
- [JankyBorders](https://github.com/FelixKratz/JankyBorders)
- `oh-my-zsh`
- `powerlevel10k` for the Zsh prompt theme
- `nvm`
- `rbenv`
- Xcode Command Line Tools, because SketchyBar helper binaries are compiled with `make`

Optional tools referenced by the configs:

- `Ghostty`
- `logo-ls`
- `SwitchAudioSource`
- `nowplaying-cli` for media playback controls
- `Vorssaint` for its menu-bar widget

## Install

Clone the repository:

```bash
git clone https://github.com/partlyjadedyouth/dotfiles.git ~/Dotfiles
cd ~/Dotfiles
```

Create the symlinks:

```bash
mkdir -p ~/.config

ln -sfn "$PWD/git/.gitconfig" ~/.gitconfig
ln -sfn "$PWD/git/.gitignore_global" ~/.gitignore_global

ln -sfn "$PWD/zsh/.zshrc" ~/.zshrc
ln -sfn "$PWD/vim/.vimrc" ~/.vimrc

ln -sfn "$PWD/aerospace/.aerospace.toml" ~/.aerospace.toml
ln -sfn "$PWD/sketchybar" ~/.config/sketchybar
ln -sfn "$PWD/borders" ~/.config/borders
ln -sfn "$PWD/ghostty" ~/.config/ghostty
```

## Extra Setup

### Zsh prompt

Powerlevel10k is the Zsh theme selected by [`zsh/.zshrc`](zsh/.zshrc). It controls the terminal prompt's appearance and can display the current directory, Git branch and status, and command duration.

With the default Oh My Zsh setup, its theme files live in `~/.oh-my-zsh/custom/themes/powerlevel10k`. Personal prompt settings are loaded from `~/.p10k.zsh` when that file exists. Run `p10k configure` in an interactive Zsh terminal to customize the prompt.

### SketchyBar

This setup compiles helper binaries from [`sketchybar/helpers/`](sketchybar/helpers/) on startup, so `make` and the macOS command line toolchain need to be available.

The bar also expects:

- the SketchyBar Lua integration to be installed
- SF Pro / SF Mono fonts, or a compatible replacement
- AeroSpace to be installed, because workspace widgets are driven by `aerospace` events and shell commands

The Vorssaint widget on the right opens the app's native menu-bar panel. If Vorssaint is not running, clicking the widget launches it first, then attempts to open the panel after a short delay. Its transparent logo is stored in [`sketchybar/assets/vorssaint.png`](sketchybar/assets/vorssaint.png).

Native menu clicks require macOS Accessibility access for SketchyBar or its `menus` helper. If access is blocked, the Vorssaint widget opens **System Settings → Privacy & Security → Accessibility**. Enable access there and click the widget again.

App icons for workspace labels combine the upstream mapping with personal overrides in [`sketchybar/helpers/app_icons_overrides.lua`](sketchybar/helpers/app_icons_overrides.lua). Refresh the upstream mapping and app font with `./sketchybar/helpers/update_app_font.sh`.

## Notable Behavior

### AeroSpace + SketchyBar integration

The workspace section in SketchyBar is driven by AeroSpace events and supports:

- dynamic workspace names
- dynamic workspace creation and removal
- per-monitor workspace visibility
- app icons per workspace
- workspace switching and moving windows by clicking the bar

Left-click a workspace to switch to it; right-click to move the focused window there and follow it. On the built-in display, empty, unfocused workspaces may be hidden to make room around the notch.

Relevant files:

- [`aerospace/.aerospace.toml`](aerospace/.aerospace.toml)
- [`sketchybar/items/spaces.lua`](sketchybar/items/spaces.lua)
- [`sketchybar/helpers/app_icons.lua`](sketchybar/helpers/app_icons.lua)
- [`sketchybar/helpers/workspaces.lua`](sketchybar/helpers/workspaces.lua): workspace parsing, sorting, item keys, and icon labels

### Workspace assignments

Newly detected windows are assigned by app:

| Workspace | Apps | Shortcut key |
| --- | --- | --- |
| `W̲eb` | Dia | `w` |
| `Note̲` | Obsidian, Notion, Apple Notes | `e` |
| `C̲omm` | Slack, KakaoTalk, Calendar | `c` |
| `A̲I` | ChatGPT, Codex, Claude | `a` |
| `D̲ev` | VS Code, Ghostty | `d` |
| `R̲ead` | Preview, Zotero | `r` |
| `M̲usic` | Spotify | `m` |
| `Z1` | Apps without an assignment | `1` |
| `Z2` | Manual grouping | `2` |

The seven named workspaces are persistent. The underlined letters are part of their names, so copy the exact names when editing commands.

Window callbacks run in this order: notify SketchyBar, apply matching floating layouts, choose a workspace. Floating rules continue processing; a matching workspace assignment stops processing. The last rule uses `if = 'true'` to send unmatched apps to `Z1`.

To assign another app, extend the matching workspace rule or add a rule before the final `Z1` fallback with `check-further-callbacks = false`. There is no separate exclusion list to maintain.

Assignments run when windows are detected. Moving an existing window manually does not cause it to be reassigned, and reloading the config does not reroute existing windows.

### AeroSpace bindings

The AeroSpace config includes bindings for:

- directional focus and window swapping
- moving windows between monitors and workspaces
- previous/next workspace navigation
- summoning workspaces
- resizing, balancing, and layout changes
- toggling floating and fullscreen modes
- launching `Ghostty` with `alt-enter`

For each shortcut key in the workspace table:

- `alt-cmd-<key>` switches to the workspace
- `alt-shift-<key>` moves the focused window there and follows it
- `alt-cmd-shift-<key>` summons the workspace to the focused monitor

After editing the configs, validate and reload AeroSpace, then reload SketchyBar:

```bash
aerospace reload-config --dry-run --no-gui --warnings-as-errors
aerospace reload-config --no-gui
sketchybar --reload
```

`ctrl-alt-r` also reloads the AeroSpace config.

## Repository Layout

```text
.
|-- aerospace/
|-- borders/
|-- ghostty/
|-- git/
|-- sketchybar/
|   |-- assets/
|   |-- helpers/
|   `-- items/
|-- vim/
`-- zsh/
```
