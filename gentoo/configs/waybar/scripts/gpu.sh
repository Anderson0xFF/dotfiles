#!/usr/bin/env bash
# Lê uso de VRAM e ocupação da GPU AMD via sysfs (driver amdgpu)
# e emite JSON para o módulo custom/gpu da waybar.

dev=/sys/class/drm/card0/device

read -r used_b  < "$dev/mem_info_vram_used"
read -r total_b < "$dev/mem_info_vram_total"
read -r busy    < "$dev/gpu_busy_percent"

used_gib=$(awk  -v b="$used_b"  'BEGIN { printf "%.1f", b/1024/1024/1024 }')
total_gib=$(awk -v b="$total_b" 'BEGIN { printf "%.1f", b/1024/1024/1024 }')
pct=$(( used_b * 100 / total_b ))

printf '{"text":"","tooltip":"GPU: %s%% · VRAM %s GiB / %s GiB (%s%%)","percentage":%s}\n' \
  "$busy" "$used_gib" "$total_gib" "$pct" "$pct"
