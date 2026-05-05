#!/usr/bin/env python3
"""Título da música com marquee (scroll horizontal) para o waybar.

Este script é o dono da escolha de player. Ele grava o player ativo em
ACTIVE_PLAYER_FILE; os demais scripts da ilha (botões, cava, wrapper de
comandos) leem esse arquivo para garantir que o que é exibido é o que é
controlado quando o usuário clica.
"""
import json
import subprocess
from html import escape as html_escape
from pathlib import Path

PLAYERCTL = "playerctl"
WIDTH = 20
SEPARATOR = "   •   "

STATE_DIR = Path("/tmp")
OFFSET_FILE = STATE_DIR / "waybar-mpris-offset"
LAST_TITLE_FILE = STATE_DIR / "waybar-mpris-last-title"
ACTIVE_PLAYER_FILE = STATE_DIR / "waybar-mpris-player"

# Prioridade por prefixo: quem aparecer antes ganha, independente do status,
# para que o player preferido (Spotify) continue sendo o ativo mesmo quando
# pausado e outro player secundário estiver tocando.
PREFERENCE = ("spotify", "firefox", "chromium")


def pref_key(name: str) -> int:
    for i, prefix in enumerate(PREFERENCE):
        if name.startswith(prefix):
            return i
    return len(PREFERENCE)


def list_players() -> list[str]:
    try:
        out = subprocess.run(
            [PLAYERCTL, "-l"], capture_output=True, text=True, check=False,
        ).stdout
    except FileNotFoundError:
        return []
    return [n for n in out.splitlines() if n]


def player_status(name: str) -> str:
    return subprocess.run(
        [PLAYERCTL, "--player", name, "status"],
        capture_output=True, text=True, check=False,
    ).stdout.strip()


def select_player() -> str | None:
    """Escolhe o player ativo, ignorando os que estão em Stopped.

    Prioridade declarada sobrepõe o status: Spotify pausado é preferido a
    Firefox tocando. Isso deixa a ilha estável e previsível para o usuário.
    """
    candidates = [
        (name, player_status(name)) for name in list_players()
    ]
    eligible = [(n, s) for n, s in candidates if s in ("Playing", "Paused")]
    if not eligible:
        return None
    eligible.sort(key=lambda ns: (pref_key(ns[0]), ns[0]))
    return eligible[0][0]


def playerctl_for(player: str, *args: str) -> str:
    return subprocess.run(
        [PLAYERCTL, "--player", player, *args],
        capture_output=True, text=True, check=False,
    ).stdout.strip()


def emit(text: str, cls: str, tooltip: str = "") -> None:
    payload = {"text": text, "class": cls, "alt": cls}
    if tooltip:
        payload["tooltip"] = tooltip
    print(json.dumps(payload, ensure_ascii=False))


def marquee(full: str) -> str:
    if len(full) <= WIDTH:
        return full

    padded = full + SEPARATOR
    plen = len(padded)

    last_title = LAST_TITLE_FILE.read_text() if LAST_TITLE_FILE.exists() else ""
    try:
        offset = int(OFFSET_FILE.read_text()) if OFFSET_FILE.exists() else 0
    except ValueError:
        offset = 0

    if last_title != full:
        offset = 0

    LAST_TITLE_FILE.write_text(full)
    OFFSET_FILE.write_text(str((offset + 1) % plen))

    doubled = padded + padded
    return doubled[offset : offset + WIDTH]


def clear_active_player() -> None:
    try:
        ACTIVE_PLAYER_FILE.unlink()
    except FileNotFoundError:
        pass


def main() -> None:
    player = select_player()
    if not player:
        clear_active_player()
        emit("", "stopped")
        return

    status = playerctl_for(player, "status")
    if status not in ("Playing", "Paused"):
        clear_active_player()
        emit("", "stopped")
        return

    ACTIVE_PLAYER_FILE.write_text(player)

    title = playerctl_for(player, "metadata", "title")
    artist = playerctl_for(player, "metadata", "artist")
    album = playerctl_for(player, "metadata", "album")
    player_name = playerctl_for(player, "metadata", "--format", "{{playerName}}")

    full = f"{artist} · {title}" if artist else title
    display = html_escape(marquee(full))
    cls = status.lower()
    tooltip = html_escape(f"{player_name}: {status}\n{title}\n{artist}\n{album}")
    emit(display, cls, tooltip)


if __name__ == "__main__":
    main()
