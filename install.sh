#!/bin/bash

# Black        0;30     Dark Gray     1;30
# Red          0;31     Light Red     1;31
# Green        0;32     Light Green   1;32
# Brown/Orange 0;33     Yellow        1;33
# Blue         0;34     Light Blue    1;34
# Purple       0;35     Light Purple  1;35
# Cyan         0;36     Light Cyan    1;36
# Light Gray   0;37     White         1;37

# Reset
Color_Off='\033[0m'       # Text Reset

# Regular Colors
Black='\033[0;30m'        # Black
Red='\033[0;31m'          # Red
Green='\033[0;32m'        # Green
Yellow='\033[0;33m'       # Yellow
Blue='\033[0;34m'         # Blue
Purple='\033[0;35m'       # Purple
Cyan='\033[0;36m'         # Cyan
White='\033[0;37m'        # White

echo "Install desktop ..."

install() {
    if grep -q "Arch Linux"  /etc/os-release
    then
        echo -e "${Blue}Operation System detected: ArchLinux${Color_Off}"
        chmox +x install_arch.sh
        ./install_arch.sh
    elif grep -q "void" /etc/os-release
    then
        echo "Operation System detected: Void Linux"
		chmox +x install_void.sh
        ./install_void.sh
    else
        echo "System not supported."
        return 1
    fi
    cd $HOME/dotfiles/
    echo "Install configurations.."
    cp -r .config $HOME/
    echo "Install icons.."
    cp -r .icons $HOME/
    echo "Install themes.."
    cp -r .themes $HOME/
    echo "Install wallpapers.."
    cp -r wallpapers $HOME/
    echo "Install p10k config.."
    cp .p10k.zsh $HOME/
    echo "Install zshrc.."
    cp .zshrc $HOME/
    
    echo "Install Nerd Fonts .."
    cd /tmp/
    git clone https://github.com/ryanoasis/nerd-fonts
    cd nerd-fonts
    chmod +x ./install.sh
    ./install.sh
    fc-cache -f -v
    
    echo "Install PowerLevel10K .."
    cd $HOME
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/powerlevel10k
    
    echo "Install Rust Lang .."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
    source $HOME/.cargo/env

    echo "Install system tools .."
    cargo install exa bat ytop procs
    
    echo "Install ASDF .."
    cd $HOME
    git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.9.0
    
}

install
