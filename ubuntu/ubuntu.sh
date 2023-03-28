echo "Install essential"
sudo apt install git preload zsh curl gnome-shell-extensions \
gnome-shell-extension-manager chrome-gnome-shell 

echo "Install my dev-base"
sudo apt install build-essential libglew-dev libglfw3-dev cmake clang \
llvm libboost-system-dev libboost-filesystem-dev libboost-iostreams-dev \
libcrypto++-dev libboost-date-time-dev kcachegrind

echo "Remove Firefox Snap and Snap Store"
sudo snap remove firefox snap-store
sudo apt remove gnome-software-plugin-snap

echo "Install Gnome Software and Flatpak support"
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
sudo apt install gnome-software gnome-software-plugin-flatpak


#echo "Install Extensions"
#cp ~/dotfiles/extensions ~/.local/share/gnome-shell/extensions/

echo "Install BlackBox Terminal"
flatpak install flathub com.raggesilver.BlackBox
cp $HOME/dotfiles/blackbox-themes/* $HOME/.var/app/com.raggesilver.BlackBox/data/blackbox/schemes

echo "Customize Gnome Desktop"
sudo apt-get purge info
gsettings set org.gnome.shell.extensions.dash-to-dock click-action 'minimize'
gsettings set org.gnome.shell.extensions.dash-to-dock show-apps-at-top true
gsettings set org.gnome.shell.extensions.dash-to-dock dash-max-icon-size 16
gsettings set org.gnome.shell.extensions.dash-to-dock dock-position BOTTOM
gsettings set org.gnome.mutter center-new-windows true

echo "Install Kora icons"
cd $HOME
mkdir .icons
git clone https://github.com/bikass/kora.git
cd kora
mv kora-light-panel .icons/
mv kora-light .icons/
mv kora-pgrey .icons/
mv kora .icons/
cd $HOME

#gsettings set org.gnome.desktop.interface icon-theme 'kora'



#cd /usr/share/icons/Yaru/scalable/actions/ && sudo cp view-app-grid-symbolic.svg view-app-grid-symbolic.svg.bak
#sudo cp ~/dotfiles/ubuntu-icon.svg /usr/share/icons/Yaru/scalable/actions/view-app-grid-symbolic.svg

echo "Install Docker"

sudo apt-get install \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt update
sudo apt install docker-ce docker-ce-cli containerd.io docker-compose-plugin
sudo usermod -aG docker $USER
sudo systemctl enable docker.service
sudo systemctl enable containerd.service
echo "Docker installed"
