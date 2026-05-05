#!/usr/bin/env bash
output=$(makoctl list -j 2>/dev/null)
count=$(echo "$output" | jq -r 'if type == "array" then length elif .data then (.data[0] | length) else 0 end' 2>/dev/null)
count=${count:-0}

if [ "$count" -gt 0 ]; then
  icon='<span font="Symbols Nerd Font Mono">󱅫</span>'
  class="has-notifications"
else
  icon='<span font="Symbols Nerd Font Mono">󰂚</span>'
  class="none"
fi

jq -nc --arg text "$icon" --arg class "$class" '{text: $text, class: $class, alt: $class}'
