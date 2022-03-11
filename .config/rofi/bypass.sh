confirm_exit() {
    rofi -dmenu\
    -password\
    -i\
    -no-fixed-num-lines\
    -p "Password?: "\
    -theme styles/confirm.rasi
}

pass=$(confirm_exit &)
echo $pass