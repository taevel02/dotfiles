# dotfiles

Personal macOS configurations and bootstrap setup.

## Installation & Setup

```bash
git clone https://github.com/taevel02/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh
```

### Options

```bash
./install.sh --dry-run   # Simulate installation without making changes
./install.sh --force     # Force re-linking all symlinks
./install.sh --skip-brew # Skip Homebrew package installation
```

## Structure

* `install.sh`: Automated bootstrap install script
* `Brewfile`: Homebrew CLI packages, GUI applications, and fonts
* `.zshrc`: Zsh shell configurations and aliases
* `.opencommit`: OpenCommit AI commit message generator configuration
* `.config/`:
  * `ghostty/`: Ghostty terminal emulator configuration
  * `helix/`: Helix editor & LSP configuration
  * `starship.toml`: Starship shell prompt configuration
  * `yazi/`: Yazi terminal file manager configuration


