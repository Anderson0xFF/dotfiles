#!/usr/bin/env python3
"""Botão previous. Lê o player ativo do arquivo de estado escrito por
mpris-title."""
import json
import subprocess
from pathlib import Path

PLAYERCTL = "playerctl"
ACTIVE_PLAYER_FILE = Path("/tmp/waybar-mpris-player")

GLYPH_PREV = "\uf04a"


def active_player() -> str | None:
    try:
        name = ACTIVE_PLAYER_FILE.read_text().strip()
    except FileNotFoundError:
        return None
    return name or None


def player_status(name: str) -> str:
    return subprocess.run(
        [PLAYERCTL, "--player", name, "status"],
        capture_output=True, text=True, check=False,
    ).stdout.strip()


def main() -> None:
    player = active_player()
    status = player_status(player) if player else ""

    if status not in ("Playing", "Paused"):
        print(json.dumps({"text": "", "class": "stopped", "alt": "stopped"}))
        return

    cls = status.lower()
    text = f'<span font="Symbols Nerd Font Mono 14">{GLYPH_PREV}</span>'
    payload = {"text": text, "class": cls, "alt": cls, "tooltip": "Anterior"}
    print(json.dumps(payload, ensure_ascii=False))


if __name__ == "__main__":
    main()
