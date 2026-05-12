export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="comfyline"
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=244'

setopt combiningchars

# NVM lazy load
#export NVM_LAZY_LOAD=true
#source "$HOME/.zsh-nvm.zsh" --no-use


plugins=(
  git
  zsh-autosuggestions
  colored-man-pages
)

DISABLE_AUTO_UPDATE=true
source $ZSH/oh-my-zsh.sh

### PATH cleanup
export PATH="$PATH:$HOME/.local/bin"
export PATH="$PATH:$HOME/go/bin"
export PATH="$PATH:/opt/jadx/bin"
export PATH="$PATH:$HOME/.bun/bin"
export PATH="$PATH:/opt/splunk/bin"
#export PATH="$PATH:/opt/john/run"
export PATH="$PATH:/opt/bloodhound/"

### Aliasesalias fetch='fastfetch'
alias ff='fastfetch'
alias john="/opt/john/run/john"

# Bun completions
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

# Brew
#eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"


#this is tricky
alias python='python3'
alias ssh='kitten ssh'
alias firefox='firefox-beta'





