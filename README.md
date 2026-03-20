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

## Platform Assumptions

These dotfiles are intended for macOS and assume Apple Silicon-style Homebrew paths such as `/opt/homebrew/...`.

Some configs also assume these tools are installed:

- [Homebrew](https://brew.sh/)
- [AeroSpace](https://github.com/nikitabobko/AeroSpace)
- [SketchyBar](https://felixkratz.github.io/SketchyBar/)
- [JankyBorders](https://github.com/FelixKratz/JankyBorders)
- `oh-my-zsh`
- `powerlevel10k`
- `nvm`
- `rbenv`
- Anaconda or Miniconda if you want the existing `conda` initialization to work
- Xcode Command Line Tools, because SketchyBar helper binaries are compiled with `make`

Optional tools referenced by the configs:

- `Ghostty`
- `logo-ls`
- `SwitchAudioSource`

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
```

## Extra Setup

### SketchyBar

This setup compiles helper binaries from [`sketchybar/helpers/`](sketchybar/helpers/) on startup, so `make` and the macOS command line toolchain need to be available.

The bar also expects:

- the SketchyBar Lua integration to be installed
- SF Pro / SF Mono fonts, or a compatible replacement
- AeroSpace to be installed, because workspace widgets are driven by `aerospace` events and shell commands

## Notable Behavior

### AeroSpace + SketchyBar integration

The workspace section in SketchyBar is driven by AeroSpace events and supports:

- dynamic workspace names
- dynamic workspace creation and removal
- per-monitor workspace visibility
- app icons per workspace
- workspace switching and moving windows by clicking the bar

Relevant files:

- [`aerospace/.aerospace.toml`](aerospace/.aerospace.toml)
- [`sketchybar/items/spaces.lua`](sketchybar/items/spaces.lua)
- [`sketchybar/helpers/app_icons.lua`](sketchybar/helpers/app_icons.lua)

### AeroSpace bindings

The AeroSpace config includes bindings for:

- directional focus and window swapping
- moving windows between monitors and workspaces
- previous/next workspace navigation
- summoning workspaces
- resizing, balancing, and layout changes
- toggling floating and fullscreen modes
- launching `Ghostty` with `alt-enter`

## Repository Layout

```text
.
|-- aerospace/
|-- borders/
|-- git/
|-- sketchybar/
|   |-- helpers/
|   `-- items/
|-- vim/
`-- zsh/
```
