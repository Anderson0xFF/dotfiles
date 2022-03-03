# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

source /usr/share/zsh-theme-powerlevel10k/powerlevel10k.zsh-theme
source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh
source ~/.zsh/zsh-history-substring-search.zsh
source /opt/asdf-vm/asdf.sh
#source ~/.config/colors

bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

alias pacman="sudo pacman"
alias upgrade="yay"
alias cat="bat --style=auto"
alias top="ytop"
alias ls="exa --icons"
alias neofetch="neofetch --ascii_distro clear_linux"
alias distro="neofetch --ascii_distro clear_linux"
alias vim="~/.local/bin/lvim"
alias lvim="~/.local/bin/lvim"
alias pip="~/.local/bin/pip"
alias django="~/.local/bin/pip django"

export PATH="$PATH:$(yarn global bin)"

