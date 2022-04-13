#!/bin/bash

sudo xbps-install -Su
sudo xbps-install void-repo-nonfree
sudo xbps-install -Suv

sudo xbps-install -S bspwm sxhkd zsh cmake gcc \
	llvm rofi ranger neovim Thunar python \
	feh nitrogen wget curl xorg xinit firefox \
	neofetch ninja dunst alacritty scrot picom polybar \
	betterlockscreen xdg-user-dirs base-devel libXrandr-devel \
	upower libXScrnSaver-devel docker vlc thunar-volman gvfs openssl-devel

sudo usermod -aG docker $USER
sudo ln -s /etc/sv/docker /var/service/

echo "Directory update"
xdg-user-dirs-update

echo "Install Consolas Fonts"
cd /tmp/ && mkdir consolas-font
cd consolas-font
wget https://github.com/pensnarik/consolas-font/raw/master/consolas-fonts-tts.tar.bz2
tar -xf consolas-fonts-tts.tar.bz2 && rm -rf consolas-fonts-tts.tar.bz2
cd /tmp/
sudo mv consolas-font /usr/share/fonts/TTF/
fc-cache -fv
sudo fc-cache -s

echo "Install Void Packages Repository"
git clone https://github.com/void-linux/void-packages.git ~/.void-packages
cd ~/.void-packages
./xbps-src binary-bootstrap
echo XBPS_ALLOW_RESTRICTED=yes >> etc/conf
echo XBPS_MAKEJOBS=4 >> etc/conf

echo "Install Microsoft Visual Studio Code"
cd $HOME
curl -L -o vscode.tar.gz https://code.visualstudio.com/sha/download\?build\=stable\&os\=linux-x64
tar -xf vscode.tar.gz
sudo mv VSCode-linux-x64 /opt/vscode

sudo cp $HOME/dotfiles/vscode.desktop /usr/share/application/
