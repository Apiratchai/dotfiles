export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="comfyline"
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=244'

setopt combiningchars

# NVM lazy load
export NVM_LAZY_LOAD=true
source "$HOME/.zsh-nvm.zsh" --no-use


plugins=(
  git
  zsh-autosuggestions
  colored-man-pages
)

source $ZSH/oh-my-zsh.sh

### PATH cleanup
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/go/bin:$PATH"
export PATH="/opt/jadx/bin:$PATH"
export PATH="/opt/john/run:$PATH"
export PATH="$HOME/.bun/bin:$PATH"

### Aliases
alias john='/opt/john/run/john'
alias fetch='fastfetch'
alias ff='fastfetch'

# Bun completions
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

# Brew
#eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

