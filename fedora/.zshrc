HISTFILE=~/.histfile
HISTSIZE=4000
SAVEHIST=4000

source $HOME/.asdf/asdf.sh

alias dnf="sudo dnf"
alias cat="bat --style=auto"
alias ls="exa --icons"
#alias top="ytop"
alias vcpkg="~/.vcpkg/vcpkg"
alias lvim="~/.local/bin/lvim"
alias pip="~/.local/bin/pip"
alias django="~/.local/bin/pip django"
alias neofetch="neofetch --ascii_distro macos"

export PATH="$PATH:$(yarn global bin)"

eval "$(oh-my-posh init zsh --config ~/.poshthemes/amro.omp.json)"
