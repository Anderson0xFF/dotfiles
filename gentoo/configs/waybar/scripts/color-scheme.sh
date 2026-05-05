#!/usr/bin/env bash
set -euo pipefail

ICON_DARK=$'\U000F0594'   # 󰖔 weather-night (lua)
ICON_LIGHT=$'\U000F00E0'  # 󰃠 brightness-7 (sol)

action="${1:-status}"

current="$(gsettings get org.gnome.desktop.interface color-scheme 2>/dev/null | tr -d \"\')"

set_qt_scheme() {
  local mode="$1"
  local qt5_conf="$HOME/.config/qt5ct/qt5ct.conf"
  local qt6_conf="$HOME/.config/qt6ct/qt6ct.conf"
  local qt5_path qt6_path
  if [[ "$mode" == "dark" ]]; then
    qt5_path="/usr/share/qt5ct/colors/darker.conf"
    qt6_path="/usr/share/qt6ct/colors/darker.conf"
  else
    qt5_path="/usr/share/qt5ct/colors/airy.conf"
    qt6_path="/usr/share/qt6ct/colors/airy.conf"
  fi
  for pair in "$qt5_conf|$qt5_path" "$qt6_conf|$qt6_path"; do
    local conf="${pair%|*}" path="${pair#*|}"
    [[ -f "$conf" ]] || continue
    sed -i -E "s|^color_scheme_path=.*|color_scheme_path=${path}|" "$conf"
  done
}

if [[ "$action" == "toggle" ]]; then
  if [[ "$current" == "prefer-dark" ]]; then
    gsettings set org.gnome.desktop.interface color-scheme 'default'
    gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita'
    set_qt_scheme light
  else
    gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
    gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita-dark'
    set_qt_scheme dark
  fi
  pkill -RTMIN+9 waybar 2>/dev/null || true
  exit 0
fi

if [[ "$current" == "prefer-dark" ]]; then
  icon="<span font=\"Symbols Nerd Font Mono\">${ICON_DARK}</span>"
  tooltip="Tema: Escuro (clique para Claro)"
  class="dark"
else
  icon="<span font=\"Symbols Nerd Font Mono\">${ICON_LIGHT}</span>"
  tooltip="Tema: Claro (clique para Escuro)"
  class="light"
fi

jq -nc --arg text "$icon" --arg tooltip "$tooltip" --arg class "$class" \
  '{text: $text, tooltip: $tooltip, class: $class, alt: $class}'
