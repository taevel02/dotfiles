#!/usr/bin/env bash

# macOS Dotfiles Bootstrap & Install Script
#
# This script sets up a fresh macOS machine with:
# - Xcode Command Line Tools
# - Homebrew & Brewfile packages
# - Zsh plugins (autosuggestions, syntax-highlighting)
# - Symbolic links for dotfiles

set -e

# ANSI Color Codes
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}=========================================${NC}"
echo -e "${BLUE}    macOS Development Environment Setup   ${NC}"
echo -e "${BLUE}=========================================${NC}"

DOTFILES_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

# 1. Platform validation (macOS only)
if [[ "$OSTYPE" != "darwin"* ]]; then
  echo -e "${RED}Error: This script is only supported on macOS.${NC}"
  exit 1
fi

# 2. Check and install Xcode Command Line Tools
if ! xcode-select -p &>/dev/null; then
  echo -e "${YELLOW}Installing Xcode Command Line Tools...${NC}"
  xcode-select --install
  echo -e "${YELLOW}Please wait for installation to complete, then re-run this script.${NC}"
  exit 0
else
  echo -e "${GREEN}✓ Xcode Command Line Tools already installed${NC}"
fi

# 3. Check and install Homebrew
if ! command -v brew &>/dev/null; then
  echo -e "${YELLOW}Homebrew not found. Installing Homebrew...${NC}"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  
  # Load Homebrew environment variables immediately
  if [[ -f /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [[ -f /usr/local/bin/brew ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
  fi
else
  echo -e "${GREEN}✓ Homebrew already installed${NC}"
fi

# 4. Install Homebrew packages via Brewfile
if [ -f "$DOTFILES_DIR/Brewfile" ]; then
  echo -e "${YELLOW}Installing packages from Brewfile...${NC}"
  brew bundle --file="$DOTFILES_DIR/Brewfile"
  echo -e "${GREEN}✓ Brewfile installation completed${NC}"
else
  echo -e "${RED}Warning: Brewfile not found. Skipping package installation.${NC}"
fi

# 5. Helper function to create safe symbolic links
setup_symlink() {
  local src="$1"
  local dest="$2"

  # Create destination parent directory if missing
  mkdir -p "$(dirname "$dest")"

  if [ -L "$dest" ]; then
    local current_target
    current_target=$(readlink "$dest")
    if [ "$current_target" = "$src" ]; then
      echo -e "${GREEN}✓ Already linked:${NC} $dest"
      return
    else
      echo -e "${YELLOW}Incorrect link found. Backing up and reconnecting:${NC} $dest"
      mv "$dest" "${dest}.backup"
    fi
  elif [ -e "$dest" ]; then
    echo -e "${YELLOW}Existing file found. Creating backup:${NC} ${dest}.backup"
    mv "$dest" "${dest}.backup"
  fi

  ln -s "$src" "$dest"
  echo -e "${GREEN}✓ Symlink created:${NC} $dest -> $src"
}

# 6. Set up symbolic links
echo -e "${BLUE}-----------------------------------------${NC}"
echo -e "${BLUE}Creating symbolic links...${NC}"

setup_symlink "$DOTFILES_DIR/.zshrc" "$HOME/.zshrc"
setup_symlink "$DOTFILES_DIR/.tmux.conf" "$HOME/.tmux.conf"
setup_symlink "$DOTFILES_DIR/.dev.sh" "$HOME/.dev.sh"

setup_symlink "$DOTFILES_DIR/.config/starship.toml" "$HOME/.config/starship.toml"
setup_symlink "$DOTFILES_DIR/.config/ghostty/config" "$HOME/.config/ghostty/config"
setup_symlink "$DOTFILES_DIR/.config/helix/config.toml" "$HOME/.config/helix/config.toml"
setup_symlink "$DOTFILES_DIR/.config/helix/languages.toml" "$HOME/.config/helix/languages.toml"

# 7. Install Zsh plugins
echo -e "${BLUE}-----------------------------------------${NC}"
echo -e "${BLUE}Setting up Zsh plugins...${NC}"
mkdir -p "$HOME/.zsh"

install_zsh_plugin() {
  local repo_url="$1"
  local target_dir="$HOME/.zsh/$2"
  if [ ! -d "$target_dir" ]; then
    echo -e "${YELLOW}Cloning plugin ($2)...${NC}"
    git clone "$repo_url" "$target_dir"
    echo -e "${GREEN}✓ Plugin installed ($2)${NC}"
  else
    echo -e "${GREEN}✓ Plugin already exists ($2)${NC}"
  fi
}

install_zsh_plugin "https://github.com/zsh-users/zsh-autosuggestions" "zsh-autosuggestions"
install_zsh_plugin "https://github.com/zsh-users/zsh-syntax-highlighting" "zsh-syntax-highlighting"

echo -e "${BLUE}=========================================${NC}"
echo -e "${GREEN}🎉 Installation completed successfully!${NC}"
echo -e "${YELLOW}To apply Zsh configurations, restart your terminal or run:${NC}"
echo -e "source ~/.zshrc"
echo -e "${BLUE}=========================================${NC}"
