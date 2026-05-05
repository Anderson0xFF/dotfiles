#!/usr/bin/env python3
"""Wrapper para on-click/on-scroll da waybar. Envia play-pause/next/previous
ao player ativo escolhido por mpris-title, garantindo que o clique controla
o player que está sendo exibido."""
import subprocess
import sys
from pathlib import Path

PLAYERCTL = "playerctl"
ACTIVE_PLAYER_FILE = Path("/tmp/waybar-mpris-player")
ALLOWED = {"play-pause", "next", "previous"}


def active_player() -> str | None:
    try:
        name = ACTIVE_PLAYER_FILE.read_text().strip()
    except FileNotFoundError:
        return None
    return name or None


def main() -> None:
    if len(sys.argv) != 2 or sys.argv[1] not in ALLOWED:
        print(f"uso: {sys.argv[0]} {{play-pause|next|previous}}", file=sys.stderr)
        sys.exit(2)

    player = active_player()
    if not player:
        return

    subprocess.run([PLAYERCTL, "--player", player, sys.argv[1]], check=False)


if __name__ == "__main__":
    main()
