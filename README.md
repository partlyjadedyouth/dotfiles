# 🛠️ Dotfiles

Personal configuration files for a powerful macOS development environment.

This code isn't my original work, it is a combination and refinement of code that others have created and shared online over the past several years. 
Therefore, I do not hold the copyright.

## ✨ Overview

This repository contains my configuration files for:

- **🔧 Git** - Version control settings with global gitignore rules
- **📝 Vim** - Lightweight text editor configuration
- **🐚 Zsh** - Enhanced shell with custom aliases and functions
- **🪟 Yabai** - Tiling window manager for efficient workspace management
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
ln -s "$PWD/sketchybar" ~/.config/sketchybar

# Vim configuration
ln -s "$PWD/vim/.vimrc" ~/.vimrc

# Yabai window manager
ln -s "$PWD/yabai/.yabairc" ~/.yabairc
ln -s "$PWD/yabai/.skhdrc" ~/.skhdrc

# Zsh shell
ln -s "$PWD/zsh/.zshrc" ~/.zshrc
```
