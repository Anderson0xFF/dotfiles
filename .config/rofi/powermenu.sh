#!/bin/bash

rofi_command="rofi -theme styles/powermenu.rasi"

uptime=$(uptime -p | sed -e 's/up //g')

# Options
shutdown="襤"
reboot="勒"
lock=""
hibernate=""
logout=""
sleep="鈴"

# Variable passed to rofi
options="$shutdown
$reboot
$lock
$hibernate
$logout
$sleep"

_msg="Options  -  yes / y / no / n"

chosen="$(echo "$options" | $rofi_command -p "UP - $uptime" -dmenu -selected-row 2)"
case $chosen in $shutdown)
    if grep -q "Arch Linux" /etc/os-release; then
        systemctl shutdown
    elif grep -q "void" /etc/os-release; then
        pass=$(~/.config/rofi/bypass.sh)
        printf "%s\n" "$pass" | sudo --stdin bash -c 'shutdown -P now'
    fi
    ;;
$reboot)
    if grep -q "Arch Linux" /etc/os-release; then
        systemctl reboot
    elif grep -q "void" /etc/os-release; then
        pass=$(~/.config/rofi/bypass.sh)
        printf "%s\n" "$pass" | sudo --stdin bash -c 'reboot'
    fi
    ;;
$lock)
    betterlockscreen -l
    ;;
$hibernate)
    mpc -q pause
    if grep -q "Arch Linux" /etc/os-release; then
        systemctl hibernate
    elif grep -q "void" /etc/os-release; then
        pass=$(~/.config/rofi/bypass.sh)
        betterlockscreen -l &
        printf "%s\n" "$pass" | sudo --stdin bash -c 'zzz -S'
    fi
    ;;
$logout)
    bspc quit
    ;;

$sleep)
    if grep -q "Arch Linux" /etc/os-release; then
        systemctl suspend
    elif grep -q "void" /etc/os-release; then
        pass=$(~/.config/rofi/bypass.sh)
        betterlockscreen -l &
        printf "%s\n" "$pass" | sudo --stdin bash -c 'zzz'
    fi
    ;;
esac
