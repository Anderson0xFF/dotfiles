#!/usr/bin/env bash
# Mostra ícone do Docker e lista de containers em execução no tooltip.

icon='<span font="Symbols Nerd Font Mono">󰡨</span>'

emit() {
    jq -cn --arg text "$icon" --arg tooltip "$1" '{text: $text, tooltip: $tooltip}'
}

if ! command -v docker >/dev/null 2>&1; then
    emit "Docker não está instalado"
    exit 0
fi

if ! docker info >/dev/null 2>&1; then
    emit "Docker daemon não está em execução"
    exit 0
fi

containers=$(docker ps --format '{{.Names}}\t{{.Image}}\t{{.Status}}')

if [ -z "$containers" ]; then
    emit "Nenhum container em execução"
else
    count=$(printf '%s\n' "$containers" | wc -l)
    header="$count container(s) em execução"
    body=$(printf '%s\n' "$containers" | awk -F'\t' '{printf "• %s (%s) — %s\n", $1, $2, $3}')
    emit "$(printf '%s\n\n%s' "$header" "$body")"
fi
