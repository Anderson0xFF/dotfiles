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
Color_Off='\033[0m' # Text Reset

# Regular Colors
Black='\033[0;30m'  # Black
Red='\033[0;31m'    # Red
Green='\033[0;32m'  # Green
Yellow='\033[0;33m' # Yellow
Blue='\033[0;34m'   # Blue
Purple='\033[0;35m' # Purple
Cyan='\033[0;36m'   # Cyan
White='\033[0;37m'  # White

echo -e "${Yellow}"
cat emot.txt
echo -e "${Color_Off}"

install() {
    if grep -q "Arch Linux" /etc/os-release; then

        echo -e "${Blue}Operation System detected: Arch Linux${Color_Off}"
        chmod +x archlinux/install.sh
        ./archlinux/install.sh

    elif grep -q "void" /etc/os-release; then

        echo -e "${Green}Operation System detected: Void Linux${Color_Off}"
        chmod +x void/install.sh
        ./void/install.sh

    elif grep -q "Ubuntu" /etc/os-release; then

        echo -e "${Purple}Operation System detected: Ubuntu${Color_Off}"
        chmod +x ubuntu/install.sh
        ./ubuntu/install.sh

    elif grep -q "Fedora Linux" /etc/os-release; then

        echo -e "${Blue}Operation System detected: Fedora${Color_Off}"
        chmod +x fedora/install.sh
        ./fedora/install.sh
    
    else
        echo "System not supported."
        return 1
    fi

    # -- Install Wallpapers
    
    echo -e "${Green}Install wallpapers..${Color_Off}"
    cp -r wallpapers $HOME/

    # -- Install Nerd Fonts

    echo -e "${Green}Install Nerd Fonts..${Color_Off}"
    cd $HOME
    git clone https://github.com/ryanoasis/nerd-fonts
    cd nerd-fonts
    chmod +x ./install.sh
    ./install.sh
    fc-cache -fv
    cd ..
    rm -rf nerd-fonts

    # -- Install Rust

    echo -e "${Green}Install Rust..${Color_Off}"
    cd $HOME
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
    source $HOME/.cargo/env

    # -- Install System Tools

    echo -e "${Green}Install System Tools..${Color_Off}"
    cargo install ytop procs

    # -- Install ASDF Manager

    echo -e "${Green}Install ASDF Manage.${Color_Off}"
    cd $HOME
    git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.11.3
    source $HOME/.asdf/asdf.sh
    
    echo -e "${Green}Install NodeJS${Color_Off}"
    cd $HOME
    asdf plugin add nodejs
    asdf install nodejs latest
    asdf global nodejs latest

    echo -e "${Green}Install .NET ${Color_Off}"
    asdf plugin add dotnet-core
    asdf install dotnet-core latest
    asdf global dotnet-core latest

    # -- Install Yarn

    echo -e "${Green}Install Yarn${Color_Off}"
    cd $HOME
    npm install --global yarn
    yarn
    
    export PATH="$PATH:$(yarn global bin)"

    # -- Lunar Vim

    echo -e "${Green}Install LunarVim..${Color_Off}"
    cd $HOME
    bash <(curl -s https://raw.githubusercontent.com/lunarvim/lunarvim/master/utils/installer/install.sh)

    # -- Oh-My-Posh

    echo -e "${Green}Install Oh-My-Posh !${Color_Off}"
    sudo wget https://github.com/JanDeDobbeleer/oh-my-posh/releases/latest/download/posh-linux-amd64 -O /usr/local/bin/oh-my-posh
    sudo chmod +x /usr/local/bin/oh-my-posh
    
    mkdir ~/.poshthemes
    wget https://github.com/JanDeDobbeleer/oh-my-posh/releases/latest/download/themes.zip -O ~/.poshthemes/themes.zip
    unzip ~/.poshthemes/themes.zip -d ~/.poshthemes
    chmod u+rw ~/.poshthemes/*.omp.*
    rm ~/.poshthemes/themes.zip

    echo -e "${Green}Change Shell !${Color_Off}"
    chsh -s /bin/zsh

    echo -e "${Green}>> Finish <<${Color_Off}"

}

install
