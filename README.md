# dotfiles

Personal macOS configurations and development environment bootstrap.

## Installation

Clone the repository and run the installation script:

```bash
git clone https://github.com/taevel02/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh
```

## Structure

*   `install.sh`: Automated bootstrap install script.
*   `Brewfile`: Homebrew packages, applications, and fonts.
*   `.zshrc`: Zsh shell configurations.
*   `.tmux.conf`: Tmux multiplexer settings.
*   `.dev.sh`: Personal utility scripts.
*   `.config/`: Application settings:
    *   `ghostty/`: Ghostty terminal emulator configuration.
    *   `starship.toml`: Starship prompt configuration.
    *   `helix/`: Helix editor configuration.
