#!/bin/bash

if grep -q "Arch Linux" /etc/os-release; then
    updates=$(pacman -Qu | wc -l)
elif grep -q "void" /etc/os-release; then
    updates=$(xbps-query -u | wc -l)
elif grep -q "Ubuntu" /etc/os-release; then
    updates=$(apt list --upgradable | wc -l)
else
    echo "Unsupported"
    echo "󰫜  !"
    exit 1
fi

if [ $updates -gt 0 ]; then
    echo "%{F#FDD835}󰻌  ${updates}%{F-}"
else
    echo "%{F#50fa7b}󰕥  ${updates}%{F-}"
fi
