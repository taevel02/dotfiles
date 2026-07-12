eval "$(starship init zsh)"
eval "$(fnm env --use-on-cd --shell zsh)"

alias ls="lsd"
alias cat="bat -p"
alias prox="orbctl"
alias va="source .venv/bin/activate"
alias code="agy-ide"
alias brewup="brew update && brew upgrade && brew autoremove && brew cleanup"

alias t="tmux new -A -s main"
alias dev="$HOME/.dev.sh"

# Connect to specific windows of the 'main' tmux session
alias t1="tmux attach-session -t main:1"  # Focuses only on AI-CORE (agy + hx)
alias t2="tmux attach-session -t main:2"  # Focuses only on RUNTIME (Terminal)
alias t3="tmux attach-session -t main:3"  # Focuses only on SANDBOX (lazygit)

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

# opencode
export PATH=/Users/taehoonkwon/.opencode/bin:$PATH

# pnpm
export PNPM_HOME="/Users/taehoonkwon/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME/bin:"*) ;;
  *) export PATH="$PNPM_HOME/bin:$PATH" ;;
esac
# pnpm end
