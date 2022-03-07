#!/bin/bash

sudo xbps-install -Su
sudo xbps-install void-repo-nonfree
sudo xbps-install -Suv

sudo xbps-install -S bspwm sxhkd zsh cmake gcc \
	llvm rofi ranger neovim Thunar python \
	feh nitrogen wget vscode curl xorg xinit firefox \
	neofetch ninja dunst alacritty scrot picom polybar \
	betterlockscreen xdg-user-dirs base-devel libXrandr-devel \
	upower libXScrnSaver-devel docker

sudo usermod -aG docker $USER


echo "Directory update"
xdg-user-dirs-update

echo "Install Consolas Fonts"
cd /tmp/ && mkdir consolas-font
cd consolas-font
wget https://github.com/pensnarik/consolas-font/raw/master/consolas-fonts-tts.tar.bz2
tar -xf consolas-fonts-tts.tar.bz2 && rm -rf consolas-fonts-tts.tar.bz2
cd /tmp/
sudo mv consolas-font /usr/share/fonts/TTF && fc-cache -s


echo "Install Void Packages Repository"
git clone https://github.com/void-linux/void-packages.git ~/.void-packages
cd .void-packages
./xbps-src binary-bootstrap
echo XBPS_ALLOW_RESTRICTED=yes >> etc/conf