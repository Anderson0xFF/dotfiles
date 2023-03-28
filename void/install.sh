#!/bin/bash

sudo xbps-install -Su
sudo xbps-install void-repo-nonfree
sudo xbps-install -Suv

sudo xbps-install -S bspwm sxhkd zsh cmake gcc rofi ranger neovim Thunar \
	feh nitrogen wget curl xorg xinit firefox neofetch ninja dunst alacritty \
	picom scrot docker polybar xdg-user-dirs base-devel libXrandr-devel \
	thunar-volman gvfs openssl-devel betterlockscreen pipewire alsa-pipewire \
	upower libXScrnSaver-devel vlc pavucontrol xfce4-settings-manager

sudo ln -s /etc/sv/pipewire /var/service/


sudo usermod -aG docker $USER
sudo ln -s /etc/sv/docker /var/service/

echo "Directory update"
xdg-user-dirs-update

echo "Install Cascadia Code Fonts"
cd $HOME/dotfiles
unzip  fonts/CascadiaCode.zip
sudo mv CascadiaCode /usr/share/fonts/TTF/

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

# echo "Install GTK Themes"
# git clone https://github.com/catppuccin/gtk
# cd gtk
# python install.py all

cp .zshrc ~/