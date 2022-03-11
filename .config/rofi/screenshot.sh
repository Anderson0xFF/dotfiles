#!/bin/bash

rofi_command="rofi -theme ~/.config/rofi/styles/screenshot.rasi"

# Options
screen=""
area=""
window=""

# Variable passed to rofi
options="$screen\n$area\n$window"

chosen="$(echo "$options" | $rofi_command -p 'Screenshot' -dmenu -selected-row 1)"
case $chosen in
    $screen)
        sleep 1; scrot 'Screenshot_%Y-%m-%d_$wx$h_scrot.png' -e 'mv $f $HOME/screenshots/'
        ;;
    $area)
        scrot -s 'Screenshot_%Y-%m-%d_$wx$h_scrot.png' -e 'mv $f $HOME/screenshots/'
        ;;
    $window)
        sleep 1; scrot -u 'Screenshot_%Y-%m-%d_$wx$h_scrot.png' -e 'mv $f $HOME/screenshots/'
        ;;
esac

