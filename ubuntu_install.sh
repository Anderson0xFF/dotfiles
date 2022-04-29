sudo apt install git preload build-essential libglew-dev libglfw3-dev cmake clang \
llvm libboost-system-dev libboost-filesystem-dev libluajit-5.1-dev libboost-iostreams-dev \
libcrypto++-dev libboost-date-time-dev zsh curl

sudo snap remove firefox snap-store
sudo apt install gnome-software gnome-software-plugin-flatpak
sudo apt remove gnome-software-plugin-snap
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
flatpak install flathub org.mozilla.firefox

