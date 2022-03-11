ZSH_THEME="passion"

source $HOME/.asdf/asdf.sh

alias pacman="sudo pacman"
alias xbps-install="sudo xbps-install -Su"
alias xbps-remove="sudo xbps-remove"
alias xbps-remove-all="sudo xbps-remove -o"
alias xbps-upgrade="sudo xbps-install -Suv"
alias cat="bat --style=auto"
alias top="ytop"
alias ls="exa --icons"
alias vim="~/.local/bin/lvim"
alias lvim="~/.local/bin/lvim"
alias pip="~/.local/bin/pip"
alias django="~/.local/bin/pip django"
alias xbps-src="~/.void-packages/xbps-src"

export GITHUB_ACCESS_TOKEN="you token github notification"
export PATH="$PATH:$(yarn global bin)"
