#!/usr/bin/env bash

# macOS Dotfiles Bootstrap & Install Script
#
# Usage:
#   ./install.sh             # Standard install / update
#   ./install.sh --force     # Force re-linking existing symlinks
#   ./install.sh --dry-run   # Simulate actions without making changes
#   ./install.sh --skip-brew # Skip Homebrew bundle step

set -e

# ANSI Color & Formatting Codes
BOLD='\033[1m'
DIM='\033[2m'
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
CYAN='\033[0;36m'
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
      echo ""
      echo -e "${BOLD}Usage:${NC} ./install.sh [options]"
      echo ""
      echo -e "  ${BOLD}-f, --force${NC}      Force re-linking all symbolic links"
      echo -e "  ${BOLD}-n, --dry-run${NC}    Show what would be done without making actual changes"
      echo -e "  ${BOLD}    --skip-brew${NC}  Skip Homebrew package installation"
      echo ""
      exit 0
      ;;
    *)
      shift
      ;;
  esac
done

echo ""
echo -e "${BOLD}${BLUE}macOS Dotfiles Setup${NC}"
if [ "$DRY_RUN" = true ]; then
  echo -e "${YELLOW}[DRY-RUN / SIMULATION MODE]${NC}"
fi

DOTFILES_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

# 1. Platform validation (macOS only)
if [[ "$OSTYPE" != "darwin"* ]]; then
  echo ""
  echo -e "${RED}Error: This script is only supported on macOS.${NC}"
  exit 1
fi

# 2. Check for latest dotfiles updates via Git
echo ""
echo -e "${BOLD}${CYAN}➜ Checking for dotfiles updates...${NC}"
if [ -d "$DOTFILES_DIR/.git" ]; then
  if command -v git &>/dev/null; then
    if [ "$DRY_RUN" = true ]; then
      echo -e "  ${YELLOW}[DRY-RUN] Would check git remote and pull latest changes${NC}"
    else
      git -C "$DOTFILES_DIR" fetch origin main &>/dev/null || true
      if git -C "$DOTFILES_DIR" diff --quiet origin/main 2>/dev/null; then
        echo -e "  ${GREEN}✓ Repository is up to date${NC}"
      else
        echo -e "  ${YELLOW}→ Updating dotfiles repository (git pull)...${NC}"
        git -C "$DOTFILES_DIR" pull --rebase origin main || echo -e "  ${RED}Warning: Git pull failed or has uncommitted local changes.${NC}"
      fi
    fi
  fi
fi

# 3. Check system dependencies (Xcode CLT & Homebrew)
echo ""
echo -e "${BOLD}${CYAN}➜ Checking system requirements...${NC}"

if ! xcode-select -p &>/dev/null; then
  echo -e "  ${YELLOW}→ Xcode Command Line Tools not found. Installing...${NC}"
  if [ "$DRY_RUN" = false ]; then
    xcode-select --install
    echo -e "  ${YELLOW}Please wait for installation to complete, then re-run this script.${NC}"
    exit 0
  else
    echo -e "  ${YELLOW}[DRY-RUN] Would run: xcode-select --install${NC}"
  fi
else
  echo -e "  ${GREEN}✓ Xcode Command Line Tools installed${NC}"
fi

if ! command -v brew &>/dev/null; then
  echo -e "  ${YELLOW}→ Homebrew not found. Installing Homebrew...${NC}"
  if [ "$DRY_RUN" = false ]; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    if [[ -f /opt/homebrew/bin/brew ]]; then
      eval "$(/opt/homebrew/bin/brew shellenv)"
    elif [[ -f /usr/local/bin/brew ]]; then
      eval "$(/usr/local/bin/brew shellenv)"
    fi
  else
    echo -e "  ${YELLOW}[DRY-RUN] Would install Homebrew${NC}"
  fi
else
  echo -e "  ${GREEN}✓ Homebrew installed${NC}"
fi

# 4. Install Homebrew packages via Brewfile
echo ""
echo -e "${BOLD}${CYAN}➜ Installing Homebrew packages...${NC}"
if [ "$SKIP_BREW" = true ]; then
  echo -e "  ${YELLOW}Skipping Brewfile installation (--skip-brew)${NC}"
elif [ -f "$DOTFILES_DIR/Brewfile" ]; then
  if [ "$DRY_RUN" = true ]; then
    echo -e "  ${YELLOW}[DRY-RUN] Would run: brew bundle --file=$DOTFILES_DIR/Brewfile${NC}"
  else
    echo -e "  ${YELLOW}→ Running brew bundle...${NC}"
    brew bundle --file="$DOTFILES_DIR/Brewfile"
    echo -e "  ${GREEN}✓ Brewfile packages up to date${NC}"
  fi
else
  echo -e "  ${RED}Warning: Brewfile not found. Skipping package installation.${NC}"
fi

# 5. Helper function to create safe symbolic links
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
        echo -e "  ${GREEN}✓ Already linked:${NC} ${DIM}$dest${NC}"
      else
        echo -e "  ${YELLOW}[DRY-RUN] Would re-link:${NC} $dest -> $src"
      fi
    elif [ -e "$dest" ]; then
      echo -e "  ${YELLOW}[DRY-RUN] Would backup existing file $dest to ${dest}.backup and link to $src${NC}"
    else
      echo -e "  ${GREEN}[DRY-RUN] Would create symlink:${NC} $dest -> $src"
    fi
    return
  fi

  mkdir -p "$(dirname "$dest")"

  if [ -L "$dest" ]; then
    local current_target
    current_target=$(readlink "$dest")
    if [ "$current_target" = "$src" ] && [ "$FORCE" = false ]; then
      echo -e "  ${GREEN}✓ Already linked:${NC} ${DIM}$dest${NC}"
      return
    else
      echo -e "  ${YELLOW}→ Re-linking symlink:${NC} $dest -> $src"
      rm -f "$dest"
    fi
  elif [ -e "$dest" ]; then
    echo -e "  ${YELLOW}→ Existing file backup created:${NC} ${dest}.backup"
    mv "$dest" "${dest}.backup"
  fi

  ln -sf "$src" "$dest"
  echo -e "  ${GREEN}✓ Symlink created:${NC} $dest -> $src"
}

# 6. Set up symbolic links
echo ""
echo -e "${BOLD}${CYAN}➜ Setting up symbolic links...${NC}"

# Root dotfiles
for file in .zshrc .opencommit; do
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

# 7. Install or update Zsh plugins
echo ""
echo -e "${BOLD}${CYAN}➜ Setting up Zsh plugins...${NC}"
mkdir -p "$HOME/.zsh"

install_or_update_zsh_plugin() {
  local repo_url="$1"
  local plugin_name="$2"
  local target_dir="$HOME/.zsh/$plugin_name"

  if [ ! -d "$target_dir" ]; then
    if [ "$DRY_RUN" = true ]; then
      echo -e "  ${YELLOW}[DRY-RUN] Would clone $plugin_name${NC}"
    else
      echo -e "  ${YELLOW}→ Cloning plugin ($plugin_name)...${NC}"
      git clone "$repo_url" "$target_dir"
      echo -e "  ${GREEN}✓ Installed $plugin_name${NC}"
    fi
  else
    if [ "$DRY_RUN" = true ]; then
      echo -e "  ${YELLOW}[DRY-RUN] Would update $plugin_name${NC}"
    else
      git -C "$target_dir" pull --rebase &>/dev/null || echo -e "  ${YELLOW}Warning: Plugin update failed ($plugin_name)${NC}"
      echo -e "  ${GREEN}✓ Updated $plugin_name${NC}"
    fi
  fi
}

install_or_update_zsh_plugin "https://github.com/zsh-users/zsh-autosuggestions" "zsh-autosuggestions"
install_or_update_zsh_plugin "https://github.com/zsh-users/zsh-syntax-highlighting" "zsh-syntax-highlighting"

echo ""
if [ "$DRY_RUN" = true ]; then
  echo -e "${GREEN}🎉 Dry-run simulation completed successfully!${NC}"
else
  echo -e "${GREEN}🎉 Installation completed successfully!${NC}"
  echo -e "${DIM}To apply Zsh configurations, restart your terminal or run:${NC}"
  echo -e "  ${BOLD}source ~/.zshrc${NC}"
fi
echo ""

