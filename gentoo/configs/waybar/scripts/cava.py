#!/usr/bin/env python3
"""Waveform via cava para o waybar. Colapsa quando o player ativo (escolhido
por mpris-title) não está tocando."""
import json
import os
import signal
import subprocess
import sys
import tempfile
import time
from pathlib import Path

CAVA = "cava"
PLAYERCTL = "playerctl"

BARS = 20
FRAMERATE = 30
BARS_ICONS = ["▁", "▂", "▃", "▄", "▅", "▆", "▇", "█"]
ACTIVE_CHECK_INTERVAL = 1.0
ACTIVE_PLAYER_FILE = Path("/tmp/waybar-mpris-player")

CONFIG_TEMPLATE = f"""
[general]
bars = {BARS}
framerate = {FRAMERATE}
autosens = 1
lower_cutoff_freq = 50
higher_cutoff_freq = 10000

[input]
method = pipewire
source = auto

[output]
method = raw
raw_target = /dev/stdout
data_format = ascii
ascii_max_range = {len(BARS_ICONS) - 1}
bar_delimiter = 59
frame_delimiter = 10

[smoothing]
noise_reduction = 0.95
"""


def active_player() -> str | None:
    try:
        name = ACTIVE_PLAYER_FILE.read_text().strip()
    except FileNotFoundError:
        return None
    return name or None


def is_active_playing() -> bool:
    player = active_player()
    if not player:
        return False
    status = subprocess.run(
        [PLAYERCTL, "--player", player, "status"],
        capture_output=True, text=True, check=False,
    ).stdout.strip()
    return status == "Playing"


def emit(text: str, cls: str) -> None:
    payload = {"text": text, "class": cls, "alt": cls}
    sys.stdout.write(json.dumps(payload, ensure_ascii=False) + "\n")
    sys.stdout.flush()


def emit_empty() -> None:
    emit("", "empty")


def main() -> None:
    with tempfile.NamedTemporaryFile(
        mode="w", suffix=".conf", delete=False
    ) as cfg:
        cfg.write(CONFIG_TEMPLATE)
        cfg_path = cfg.name

    proc = subprocess.Popen(
        [CAVA, "-p", cfg_path],
        stdout=subprocess.PIPE,
        stderr=subprocess.DEVNULL,
        text=True,
        bufsize=1,
    )

    def cleanup(*_):
        try:
            proc.terminate()
        except Exception:
            pass
        try:
            os.unlink(cfg_path)
        except Exception:
            pass
        sys.exit(0)

    signal.signal(signal.SIGTERM, cleanup)
    signal.signal(signal.SIGINT, cleanup)

    last_check = 0.0
    playing = False

    try:
        for line in proc.stdout:
            now = time.monotonic()
            if now - last_check >= ACTIVE_CHECK_INTERVAL:
                playing = is_active_playing()
                last_check = now

            if not playing:
                emit_empty()
                continue

            raw = line.strip().rstrip(";")
            if not raw:
                emit_empty()
                continue

            try:
                levels = [int(x) for x in raw.split(";") if x]
            except ValueError:
                continue

            if not levels:
                emit_empty()
                continue

            bar = "".join(
                BARS_ICONS[min(max(lv, 0), len(BARS_ICONS) - 1)]
                for lv in levels
            )
            emit(bar, "playing")
    finally:
        cleanup()


if __name__ == "__main__":
    main()
