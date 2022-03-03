#!/bin/bash

install() {
	if grep -q "Arch Linux"  /etc/os-release
	then
  		echo "Operation System detected: ArchLinux"
  		chmox +x install_arch.sh
  		./install_arch.sh
	elif grep -q "void" /etc/os-release
	then
  		echo "Operation System detected: Void Linux"
  		./install_void.sh
	else
  		echo "System not supported."
  		return 1
	fi
cd $HOME/dotfiles/
echo "Install configurations.."
cp -f .config $HOME/
echo "Install icons.."
cp -f .icons $HOME/
echo "Install themes.."
cp -f .themes $HOME/
echo "Install wallpapers.."
cp -f wallpapers $HOME/
echo "Install p10k config.."
cp -f .p10k.zsh $HOME/
echo "Install zshrc.."
cp -f .zshrc $HOME/

echo "Install Nerd Fonts"
cd /tmp/
git clone https://github.com/ryanoasis/nerd-fonts
cd nerd-fonts
chmod +x ./install.sh
./install.sh
fc-cache -f -v

echo "Install PowerLevel10K"
cd /tmp/
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/powerlevel10k

echo "Install Betterlockscreen"
cd /tmp/
git clone https://github.com/betterlockscreen/betterlockscreen
cd betterlockscreen
chmod +x ./install.sh
./install.sh

echo "Install Rust Lang"
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

echo "Install system tools"
cargo install exa bat ytop procs

echo "Install ASDF"
cd $HOME
git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.9.0

}

install
