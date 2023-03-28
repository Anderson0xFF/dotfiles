HISTFILE=~/.histfile
HISTSIZE=4000
SAVEHIST=4000

export GITHUB_USER=" you user"
export GITHUB_ACCESS_TOKEN="you github notification token"


source $HOME/.asdf/asdf.sh

alias xbps-install="sudo xbps-install -Su"
alias xbps-remove="sudo xbps-remove"
alias xbps-remove-all="sudo xbps-remove -o"

alias xbps-upgrade="sudo xbps-install -Suv"
alias cat="bat --style=auto"
alias top="ytop"
alias ls="exa --icons"

alias lvim="~/.local/bin/lvim"
alias pip="~/.local/bin/pip"
alias django="~/.local/bin/pip django"
alias xbps-src="~/.void-packages/xbps-src"
alias neofetch="neofetch --ascii_distro macos"

export PATH="$PATH:$(yarn global bin)"

eval "$(oh-my-posh init zsh --config ~/.poshthemes/chips.omp.json)"