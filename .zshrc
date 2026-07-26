eval "$(starship init zsh)"
eval "$(fnm env --use-on-cd --shell zsh)"

alias ls="lsd"
alias cat="bat -p"
alias prox="orbctl"
alias va="source .venv/bin/activate"
alias brewup="brew update && brew upgrade && brew autoremove && brew cleanup"

autoload -Uz compinit
if [[ -n ~/.zcompdump(#qNmh-24) ]]; then
  compinit -C
else
  compinit
fi

zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|=*' 'l:|=* r:|=*'

bindkey -e

source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh
source ~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

export PATH="$HOME/.antigravity-ide/antigravity-ide/bin:$PATH"
export RIPGREP_CONFIG_PATH=~/.ripgreprc

# pnpm
export PNPM_HOME="/Users/taehoonkwon/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME/bin:"*) ;;
  *) export PATH="$PNPM_HOME/bin:$PATH" ;;
esac
# pnpm end
