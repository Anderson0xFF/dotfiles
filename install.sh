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

echo -e "${Yellow}"
cat emot.txt
echo -e "${Color_Off}" 

install() {
    if grep -q "Arch Linux"  /etc/os-release
    then
    
        echo -e "${Blue}Operation System detected: Arch Linux${Color_Off}"
        chmod +x install_arch.sh
        ./install_arch.sh
        
    elif grep -q "void" /etc/os-release
    then
    
        echo -e "${Green}Operation System detected: Void Linux${Color_Off}"
	chmod +x install_void.sh
        ./install_void.sh
        
    elif grep -q "Ubuntu"  /etc/os-release
    then
    
    	echo -e "${Purple}Operation System detected: Ubuntu${Color_Off}"
    	chmod +x install_ubuntu.sh
    	./install_ubuntu.sh
    	
    else
        echo "System not supported."
        return 1
    fi

    cd $HOME/dotfiles/
    echo -e "${Green}Install configurations..${Color_Off}"
    cp -r .config $HOME/

    echo -e "${Green}Install wallpapers..${Color_Off}"
    cp -r wallpapers $HOME/

    echo -e "${Green}Install Nerd Fonts..${Color_Off}"
    cd $HOME
    git clone https://github.com/ryanoasis/nerd-fonts
    cd nerd-fonts
    chmod +x ./install.sh
    ./install.sh
    fc-cache -fv
    cd ..
    rm -rf nerd-fonts

    if grep -q "Ubuntu"  /etc/os-release
    then
        echo -e "${Green}Install zshrc..${Color_Off}"
        cd $HOME/dotfiles/
        cat $HOME/dotfiles/.zshrc _ubuntu >> $HOME/.zshrc
    else 
        echo -e "${Green}Install zshrc..${Color_Off}"
        cd $HOME/dotfiles/
        cat $HOME/dotfiles/.zshrc >> $HOME/.zshrc
    fi

    echo -e "${Green}Install Rust..${Color_Off}"
    cd $HOME
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
    source $HOME/.cargo/env

    echo -e "${Green}Install system tools..${Color_Off}"
    cargo install exa bat ytop procs
    
    echo -e "${Green}Install ASDF Manage multiple runtime versions with a single CLI tool, extendable via plugins.${Color_Off}"
    cd $HOME
    git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.9.0

    echo -e "${Green}Install NodeJS..${Color_Off}"
    cd $HOME
    asdf plugin add nodejs
    asdf install nodejs latest
    asdf global nodejs latest
    
    echo -e "${Green}Install .NET..${Color_Off}"
    asdf plugin add dotnet-core
    asdf install latest
    asdf global latest
    
    
    echo -e "${Green}Install Yarn..${Color_Off}"
    echo "Install Yarn"
    cd $HOME
    npm install --global yarn
    yarn

    echo -e "${Green}Install LunarVim..${Color_Off}"
    cd $HOME
    bash <(curl -s https://raw.githubusercontent.com/lunarvim/lunarvim/master/utils/installer/install.sh)


    # echo "Install Alacritty Terminal"
    # cargo install alacritty
    # wget https://raw.githubusercontent.com/alacritty/alacritty/master/extra/logo/alacritty-term.svg
    # sudo mv alacritty-term.svg /usr/share/pixmaps/Alacritty.svg
    # sudo desktop-file-install Alacritty.desktop
    # sudo update-desktop-database

    echo "Changer Shell"
    chsh -s /bin/zsh
}

install
