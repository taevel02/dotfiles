# 🛠️ taevel02's dotfiles (macOS 개발 환경 설정)

이 저장소는 아무것도 없는 깨끗한 macOS(깡통 상태)에서 개발 환경을 손쉽게 복원하기 위해 설계된 개인 설정 저장소(dotfiles)입니다. 
쉘 설정(`zsh`), 패키지 목록(`Homebrew`), 터미널 환경(`ghostty`, `tmux`, `starship`), 포스트모던 에디터(`helix`) 및 기타 유틸리티 설정을 심볼릭 링크 형태로 동기화합니다.

---

## 📂 저장소 구성

*   **`install.sh`**: macOS 시스템 및 설정 파일 설치/연결용 통합 부트스트랩 스크립트
*   **`Brewfile`**: 홈브루로 설치할 패키지 및 애플리케이션(casks) 관리 리스트
*   **`.zshrc`**: 환경 변수, 단축키 및 앨리어스 설정 파일
*   **`.tmux.conf`**: tmux 멀티플렉서 설정
*   **`.dev.sh`**: 개인 개발 및 프로젝트 단축 스크립트
*   **`.config/`**: 하위 앱 전용 설정
    *   `ghostty/`: Ghostty 터미널 에뮬레이터 설정
    *   `starship.toml`: Starship 프롬프트 테마 설정
    *   `helix/`: Helix 에디터 (`config.toml`, `languages.toml`) 설정
*   **`.zsh/`**: Zsh 플러그인 (설치 스크립트에 의해 자동으로 다운로드됨)

---

## 🚀 복원 및 설치 방법 (새 기기 전용)

새로운 맥을 실행한 후 터미널(또는 기본 쉘)을 열고 아래 명령어를 입력하여 전체 개발 환경을 복원합니다.

```bash
# 1. dotfiles 저장소 클론
git clone https://github.com/taevel02/dotfiles.git ~/dotfiles
cd ~/dotfiles

# 2. 설치 스크립트 실행 (Homebrew 설치, Brewfile 적용, 심볼릭 링크 및 플러그인 구성)
./install.sh
```

### 💡 `install.sh` 스크립트가 수행하는 작업:
1.  **Xcode Command Line Tools** 설치 확인 및 없을 시 설치
2.  **Homebrew** 설치 확인 및 없을 시 자동 설치
3.  **`Brewfile`**에 정의된 모든 패키지, 앱, 폰트 복원 (`brew bundle`)
4.  지정된 설정 파일들을 홈 디렉토리(`~`)로 **심볼릭 링크(`ln -s`)** 연동 (기존 설정은 자동으로 `*.backup` 파일로 안전하게 이동)
5.  **Zsh 자동완성 & 하이라이팅 플러그인** (`zsh-autosuggestions`, `zsh-syntax-highlighting`, `fzf-tab`)을 `~/.zsh/` 폴더에 클론 및 활성화

---

## 🔒 로컬 전용 설정 분리 (보안)

저장소는 퍼블릭으로 공개되어 있어 API 토큰이나 비밀번호 등 민감 정보가 GitHub에 포함되면 안 됩니다.
개인적인 환경변수나 민감한 alias 등은 로컬 전용 파일인 `~/.zshrc.local` 에 별도로 작성해 주세요. (해당 파일은 Git이 추적하지 않습니다.)

```bash
# 로컬 전용 설정 파일 생성 예시
echo 'export GITHUB_TOKEN="your_token_here"' >> ~/.zshrc.local
```
※ `.zshrc` 파일이 실행될 때 `~/.zshrc.local`이 존재하면 자동으로 로드합니다.
