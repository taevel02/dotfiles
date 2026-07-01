#!/usr/bin/env bash

# macOS Dotfiles Bootstrap & Install Script
# 이 스크립트는 아무것도 설치되지 않은 macOS 깡통 환경에서 실행해도
# Homebrew, 패키지, Zsh 플러그인, 설정 파일 링크를 자동으로 구성해 줍니다.

set -e

# ANSI 색상 코드 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # 색상 초기화

echo -e "${BLUE}=========================================${NC}"
echo -e "${BLUE}    macOS Development Environment Setup   ${NC}"
echo -e "${BLUE}=========================================${NC}"

DOTFILES_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

# 1. macOS 플랫폼 체크
if [[ "$OSTYPE" != "darwin"* ]]; then
  echo -e "${RED}Error: 이 스크립트는 macOS 전용입니다.${NC}"
  exit 1
fi

# 2. Command Line Tools 설치 확인
if ! xcode-select -p &>/dev/null; then
  echo -e "${YELLOW}Xcode Command Line Tools 설치 중...${NC}"
  xcode-select --install
  echo -e "${YELLOW}설치가 완료될 때까지 기다려 주세요. 설치 후 스크립트를 재실행해야 할 수 있습니다.${NC}"
  exit 0
else
  echo -e "${GREEN}✓ Xcode Command Line Tools 이미 설치됨${NC}"
fi

# 3. Homebrew 설치 및 설정 로드
if ! command -v brew &>/dev/null; then
  echo -e "${YELLOW}Homebrew가 설치되어 있지 않습니다. 설치를 시작합니다...${NC}"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  
  # Apple Silicon 및 Intel Mac 모두에 맞게 환경변수 설정
  if [[ -f /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [[ -f /usr/local/bin/brew ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
  fi
else
  echo -e "${GREEN}✓ Homebrew 이미 설치됨${NC}"
fi

# 4. Brewfile 패키지 설치
if [ -f "$DOTFILES_DIR/Brewfile" ]; then
  echo -e "${YELLOW}Brewfile을 기반으로 프로그램 및 앱 설치 중...${NC}"
  brew bundle --file="$DOTFILES_DIR/Brewfile"
  echo -e "${GREEN}✓ Brewfile 설치 완료${NC}"
else
  echo -e "${RED}Warning: Brewfile을 찾을 수 없습니다. 패키지 설치를 건너뜁니다.${NC}"
fi

# 5. 심볼릭 링크 처리 함수 정의
setup_symlink() {
  local src="$1"
  local dest="$2"

  # 대상의 부모 디렉토리가 없으면 생성
  mkdir -p "$(dirname "$dest")"

  if [ -L "$dest" ]; then
    local current_target
    current_target=$(readlink "$dest")
    if [ "$current_target" = "$src" ]; then
      echo -e "${GREEN}✓ 이미 올바르게 링크되어 있음:${NC} $dest"
      return
    else
      echo -e "${YELLOW}잘못된 링크 발견, 백업 및 재연결:${NC} $dest"
      mv "$dest" "${dest}.backup"
    fi
  elif [ -e "$dest" ]; then
    echo -e "${YELLOW}기존 파일 발견, 백업 생성:${NC} ${dest}.backup"
    mv "$dest" "${dest}.backup"
  fi

  ln -s "$src" "$dest"
  echo -e "${GREEN}✓ 심볼릭 링크 생성 완료:${NC} $dest -> $src"
}

# 6. 설정 파일 심볼릭 링크 연결
echo -e "${BLUE}-----------------------------------------${NC}"
echo -e "${BLUE}설정 파일 심볼릭 링크 구성 시작...${NC}"

# 파일 링킹
setup_symlink "$DOTFILES_DIR/.zshrc" "$HOME/.zshrc"
setup_symlink "$DOTFILES_DIR/.tmux.conf" "$HOME/.tmux.conf"
setup_symlink "$DOTFILES_DIR/.dev.sh" "$HOME/.dev.sh"

# 폴더/세부 설정 링킹 (.config 하위)
setup_symlink "$DOTFILES_DIR/.config/starship.toml" "$HOME/.config/starship.toml"
setup_symlink "$DOTFILES_DIR/.config/ghostty/config" "$HOME/.config/ghostty/config"
setup_symlink "$DOTFILES_DIR/.config/helix/config.toml" "$HOME/.config/helix/config.toml"
setup_symlink "$DOTFILES_DIR/.config/helix/languages.toml" "$HOME/.config/helix/languages.toml"

# 7. Zsh 플러그인 디렉토리 및 플러그인 설치
echo -e "${BLUE}-----------------------------------------${NC}"
echo -e "${BLUE}Zsh 플러그인 설치 및 구성...${NC}"
mkdir -p "$HOME/.zsh"

install_zsh_plugin() {
  local repo_url="$1"
  local target_dir="$HOME/.zsh/$2"
  if [ ! -d "$target_dir" ]; then
    echo -e "${YELLOW}플러그인 다운로드 중 ($2)...${NC}"
    git clone "$repo_url" "$target_dir"
    echo -e "${GREEN}✓ 플러그인 다운로드 완료 ($2)${NC}"
  else
    echo -e "${GREEN}✓ 플러그인 이미 존재함 ($2)${NC}"
  fi
}

install_zsh_plugin "https://github.com/zsh-users/zsh-autosuggestions" "zsh-autosuggestions"
install_zsh_plugin "https://github.com/zsh-users/zsh-syntax-highlighting" "zsh-syntax-highlighting"
install_zsh_plugin "https://github.com/Aloxaf/fzf-tab" "fzf-tab"

echo -e "${BLUE}=========================================${NC}"
echo -e "${GREEN}🎉 개발 환경 설치 및 설정이 완료되었습니다!${NC}"
echo -e "${YELLOW}Zsh 설정을 적용하려면 터미널을 다시 켜거나 다음 명령을 실행하세요:${NC}"
echo -e "source ~/.zshrc"
echo -e "${BLUE}=========================================${NC}"
