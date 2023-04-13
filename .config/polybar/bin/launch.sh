#! /bin/bash
pkill polybar

while pgrep -u $UID -x polybar >/dev/null; do sleep 1; done

# Launch the bar
polybar -q main -c ~/.config/polybar/$polybar_theme/config.ini &
