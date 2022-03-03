confirm_exit() {
	rofi -dmenu\
    -password\
		-i\
		-no-fixed-num-lines\
		-p "Password?: "\
		-theme styles/confirm.rasi
}

pass=$(confirm_exit &)

sudo -k
printf "%s\n" "$pass" | sudo --stdin bash -c 'yes | pacman -Syu'
