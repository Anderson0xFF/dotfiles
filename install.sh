#!/bin/bash

if grep -q "Arch Linux"  /etc/os-release
then
  echo "Operation System detected: ArchLinux"
  chmox +x install_arch.sh
  ./install_arch.sh
elif grep -q "Void Linux" /etc/os-release
  echo "Operation System detected: Void Linux"
else
  echo "System not supported."
  return
fi

echo "Install configurations.."
cp .config $HOME/
echo "Install icons.."
cp .icons $HOME/
echo "Install themes.."
cp .themes $HOME/
echo "Install wallpapers.."
cp wallpapers $HOME/
echo "Install p10k config.."
cp .p10k.zsh $HOME/
echo "Install zshrc.."
cp .zshrc $HOME/

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
