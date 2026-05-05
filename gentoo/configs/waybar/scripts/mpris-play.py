#!/usr/bin/env python3
"""Botão play/pause. Lê o player ativo do arquivo de estado escrito por
mpris-title para garantir que o botão reflete o player exibido."""
import json
import subprocess
from pathlib import Path

PLAYERCTL = "playerctl"
ACTIVE_PLAYER_FILE = Path("/tmp/waybar-mpris-player")

GLYPH_PLAY = "\uf04b"
GLYPH_PAUSE = "\uf04c"
GLYPH_STOP = "\uf04d"


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

    if status == "Playing":
        glyph, cls = GLYPH_PAUSE, "playing"
    elif status == "Paused":
        glyph, cls = GLYPH_PLAY, "paused"
    else:
        glyph, cls = GLYPH_STOP, "stopped"

    text = f'<span font="Symbols Nerd Font Mono 14">{glyph}</span>'
    payload = {"text": text, "class": cls, "alt": cls, "tooltip": "Play/Pause"}
    print(json.dumps(payload, ensure_ascii=False))


if __name__ == "__main__":
    main()
