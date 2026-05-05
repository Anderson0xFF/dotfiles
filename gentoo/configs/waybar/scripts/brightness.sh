#!/usr/bin/env bash
set -euo pipefail

ICON=$'\U000F00DF'

if raw="$(ddcutil getvcp 10 --brief 2>/dev/null)"; then
  value="$(printf '%s\n' "$raw" | awk '{print $4}')"
  max="$(printf '%s\n' "$raw" | awk '{print $5}')"
  if [[ -n "${value:-}" && -n "${max:-}" && "$max" -gt 0 ]]; then
    pct=$(( value * 100 / max ))
    printf '{"text":"%s","tooltip":"Brightness: %d%%","class":"ok","alt":"%d"}\n' \
      "$ICON" "$pct" "$pct"
    exit 0
  fi
fi

printf '{"text":"%s","tooltip":"Brightness: unavailable","class":"error","alt":"na"}\n' "$ICON"
