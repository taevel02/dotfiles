#!/usr/bin/env bash

# macOS Dotfiles Bootstrap & Install Script
#
# Usage:
#   ./install.sh             # Standard install / update
#   ./install.sh --force     # Force re-linking existing symlinks
#   ./install.sh --dry-run   # Simulate actions without making changes
#   ./install.sh --skip-brew # Skip Homebrew bundle step

set -e

# ANSI Color Codes
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

FORCE=false
DRY_RUN=false
SKIP_BREW=false

# Parse options
while [[ $# -gt 0 ]]; do
  case $1 in
    -f|--force)
      FORCE=true
      shift
      ;;
    -n|--dry-run)
      DRY_RUN=true
      shift
      ;;
    --skip-brew)
      SKIP_BREW=true
      shift
      ;;
    -h|--help)
      echo "Usage: ./install.sh [options]"
      echo "  -f, --force      Force re-linking all symbolic links"
      echo "  -n, --dry-run    Show what would be done without making actual changes"
      echo "      --skip-brew  Skip Homebrew package installation"
      exit 0
      ;;
    *)
      shift
      ;;
  esac
done

echo -e "${BLUE}=========================================${NC}"
echo -e "${BLUE}    macOS Development Environment Setup   ${NC}"
if [ "$DRY_RUN" = true ]; then
  echo -e "${YELLOW}           [ SIMULATION / DRY-RUN ]       ${NC}"
fi
echo -e "${BLUE}=========================================${NC}"

DOTFILES_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

# 1. Platform validation (macOS only)
if [[ "$OSTYPE" != "darwin"* ]]; then
  echo -e "${RED}Error: This script is only supported on macOS.${NC}"
  exit 1
fi

# 2. Check for latest dotfiles updates via Git
echo -e "${BLUE}-----------------------------------------${NC}"
echo -e "${BLUE}Checking for dotfiles updates...${NC}"
if [ -d "$DOTFILES_DIR/.git" ]; then
  if command -v git &>/dev/null; then
    if [ "$DRY_RUN" = true ]; then
      echo -e "${YELLOW}[DRY-RUN] Checking git status and pulling latest changes in $DOTFILES_DIR${NC}"
    else
      echo -e "${YELLOW}Fetching latest changes from remote...${NC}"
      git -C "$DOTFILES_DIR" fetch origin main &>/dev/null || true
      if git -C "$DOTFILES_DIR" diff --quiet origin/main 2>/dev/null; then
        echo -e "${GREEN}✓ Dotfiles repository is up to date${NC}"
      else
        echo -e "${YELLOW}Updating dotfiles repository (git pull)...${NC}"
        git -C "$DOTFILES_DIR" pull --rebase origin main || echo -e "${RED}Warning: Git pull failed or has uncommitted local changes.${NC}"
      fi
    fi
  fi
fi

# 3. Check and install Xcode Command Line Tools
if ! xcode-select -p &>/dev/null; then
  echo -e "${YELLOW}Installing Xcode Command Line Tools...${NC}"
  if [ "$DRY_RUN" = false ]; then
    xcode-select --install
    echo -e "${YELLOW}Please wait for installation to complete, then re-run this script.${NC}"
    exit 0
  else
    echo -e "${YELLOW}[DRY-RUN] Would run: xcode-select --install${NC}"
  fi
else
  echo -e "${GREEN}✓ Xcode Command Line Tools already installed${NC}"
fi

# 4. Check and install Homebrew
if ! command -v brew &>/dev/null; then
  echo -e "${YELLOW}Homebrew not found. Installing Homebrew...${NC}"
  if [ "$DRY_RUN" = false ]; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    if [[ -f /opt/homebrew/bin/brew ]]; then
      eval "$(/opt/homebrew/bin/brew shellenv)"
    elif [[ -f /usr/local/bin/brew ]]; then
      eval "$(/usr/local/bin/brew shellenv)"
    fi
  else
    echo -e "${YELLOW}[DRY-RUN] Would install Homebrew${NC}"
  fi
else
  echo -e "${GREEN}✓ Homebrew already installed${NC}"
fi

# 5. Install Homebrew packages via Brewfile
if [ "$SKIP_BREW" = true ]; then
  echo -e "${YELLOW}Skipping Brewfile installation as requested.${NC}"
elif [ -f "$DOTFILES_DIR/Brewfile" ]; then
  echo -e "${YELLOW}Installing/Updating packages from Brewfile...${NC}"
  if [ "$DRY_RUN" = true ]; then
    echo -e "${YELLOW}[DRY-RUN] Would run: brew bundle --file=$DOTFILES_DIR/Brewfile${NC}"
  else
    brew bundle --file="$DOTFILES_DIR/Brewfile"
    echo -e "${GREEN}✓ Brewfile installation completed${NC}"
  fi
else
  echo -e "${RED}Warning: Brewfile not found. Skipping package installation.${NC}"
fi

# 6. Helper function to create safe symbolic links
setup_symlink() {
  local src="$1"
  local dest="$2"

  if [ ! -e "$src" ] && [ ! -L "$src" ]; then
    return
  fi

  if [ "$DRY_RUN" = true ]; then
    if [ -L "$dest" ]; then
      local current_target
      current_target=$(readlink "$dest")
      if [ "$current_target" = "$src" ] && [ "$FORCE" = false ]; then
        echo -e "${GREEN}✓ Already linked:${NC} $dest"
      else
        echo -e "${YELLOW}[DRY-RUN] Would re-link:${NC} $dest -> $src"
      fi
    elif [ -e "$dest" ]; then
      echo -e "${YELLOW}[DRY-RUN] Would backup existing file $dest to ${dest}.backup and link to $src${NC}"
    else
      echo -e "${GREEN}[DRY-RUN] Would create symlink:${NC} $dest -> $src"
    fi
    return
  fi

  mkdir -p "$(dirname "$dest")"

  if [ -L "$dest" ]; then
    local current_target
    current_target=$(readlink "$dest")
    if [ "$current_target" = "$src" ] && [ "$FORCE" = false ]; then
      echo -e "${GREEN}✓ Already linked:${NC} $dest"
      return
    else
      echo -e "${YELLOW}Re-linking symlink:${NC} $dest -> $src"
      rm -f "$dest"
    fi
  elif [ -e "$dest" ]; then
    echo -e "${YELLOW}Existing file found. Creating backup:${NC} ${dest}.backup"
    mv "$dest" "${dest}.backup"
  fi

  ln -sf "$src" "$dest"
  echo -e "${GREEN}✓ Symlink created:${NC} $dest -> $src"
}

# 7. Set up symbolic links
echo -e "${BLUE}-----------------------------------------${NC}"
echo -e "${BLUE}Setting up symbolic links...${NC}"

# Root dotfiles
for file in .zshrc .tmux.conf .dev.sh .opencommit; do
  if [ -f "$DOTFILES_DIR/$file" ]; then
    setup_symlink "$DOTFILES_DIR/$file" "$HOME/$file"
  fi
done

# Config directory items (.config/*)
if [ -d "$DOTFILES_DIR/.config" ]; then
  for item in "$DOTFILES_DIR/.config/"*; do
    if [ -e "$item" ]; then
      base_item=$(basename "$item")
      setup_symlink "$item" "$HOME/.config/$base_item"
    fi
  done
fi

# 8. Install or update Zsh plugins
echo -e "${BLUE}-----------------------------------------${NC}"
echo -e "${BLUE}Setting up & updating Zsh plugins...${NC}"
mkdir -p "$HOME/.zsh"

install_or_update_zsh_plugin() {
  local repo_url="$1"
  local plugin_name="$2"
  local target_dir="$HOME/.zsh/$plugin_name"

  if [ ! -d "$target_dir" ]; then
    echo -e "${YELLOW}Cloning plugin ($plugin_name)...${NC}"
    if [ "$DRY_RUN" = true ]; then
      echo -e "${YELLOW}[DRY-RUN] Would clone $repo_url to $target_dir${NC}"
    else
      git clone "$repo_url" "$target_dir"
      echo -e "${GREEN}✓ Plugin installed ($plugin_name)${NC}"
    fi
  else
    echo -e "${YELLOW}Updating plugin ($plugin_name)...${NC}"
    if [ "$DRY_RUN" = true ]; then
      echo -e "${YELLOW}[DRY-RUN] Would pull latest changes in $target_dir${NC}"
    else
      git -C "$target_dir" pull --rebase &>/dev/null || echo -e "${YELLOW}Plugin update skipped or failed ($plugin_name)${NC}"
      echo -e "${GREEN}✓ Plugin updated ($plugin_name)${NC}"
    fi
  fi
}

install_or_update_zsh_plugin "https://github.com/zsh-users/zsh-autosuggestions" "zsh-autosuggestions"
install_or_update_zsh_plugin "https://github.com/zsh-users/zsh-syntax-highlighting" "zsh-syntax-highlighting"

echo -e "${BLUE}=========================================${NC}"
if [ "$DRY_RUN" = true ]; then
  echo -e "${GREEN}🎉 Simulation completed successfully!${NC}"
else
  echo -e "${GREEN}🎉 Installation completed successfully!${NC}"
  echo -e "${YELLOW}To apply Zsh configurations, restart your terminal or run:${NC}"
  echo -e "source ~/.zshrc"
fi
echo -e "${BLUE}=========================================${NC}"
