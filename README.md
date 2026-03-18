# 🛠️ Dotfiles

Personal configuration files for a powerful macOS development environment.

This code isn't my original work, it is a combination and refinement of code that others have created and shared online over the past several years.
Therefore, I do not hold the copyright.

## ✨ Overview

This repository contains my configuration files for:

- **🔧 Git** - Version control settings with global gitignore rules
- **📝 Vim** - Lightweight text editor configuration
- **🐚 Zsh** - Enhanced shell with custom aliases and functions
- **🪟 AeroSpace** - Tiling window manager for efficient workspace management
- **📊 SketchyBar** - Modern customizable menu bar with system monitoring widgets

## 🚀 Quick Installation

Clone this repository and run the following commands to symlink all configurations:

```bash
# Clone repository
git clone https://github.com/partlyjadedyouth/dotfiles.git ~/Dotfiles
cd ~/Dotfiles

# Git configuration
ln -sf "$PWD/git/.gitconfig" ~/.gitconfig
ln -sf "$PWD/git/.gitignore_global" ~/.gitignore_global

# SketchyBar configuration (create config directory if needed)
mkdir -p ~/.config
ln -sf "$PWD/sketchybar" ~/.config/sketchybar

# Vim configuration
ln -sf "$PWD/vim/.vimrc" ~/.vimrc

# AeroSpace window manager
ln -sf "$PWD/aerospace/.aerospace.toml" ~/.aerospace.toml

# Jankyborders
ln -sf "$PWD/borders" ~/.config/borders

# Zsh shell
ln -sf "$PWD/zsh/.zshrc" ~/.zshrc
```

## 🧩 SketchyBar + AeroSpace

The workspace section in SketchyBar is driven by AeroSpace events and supports:

- Dynamic workspace names (numeric/alphabetic/custom)
- Dynamic workspace count (no fixed workspace list)
- Per-monitor workspace visibility (each display shows only its own workspaces)
- App icons per workspace, refreshed when windows/apps are created, focused, or closed

Relevant files:

- [`aerospace/.aerospace.toml`](aerospace/.aerospace.toml)
- [`sketchybar/items/spaces.lua`](sketchybar/items/spaces.lua)
- [`sketchybar/helpers/app_icons.lua`](sketchybar/helpers/app_icons.lua)
