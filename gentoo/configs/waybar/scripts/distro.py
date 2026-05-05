#!/usr/bin/env python3
"""Mostra ícone e informações da distribuição Linux para o waybar."""
import json
import platform

DISTROS = {
    "nixos":       ("\U000f1105", "NixOS",       "#00C2DF"),
    "ubuntu":      ("\uf31b",     "Ubuntu",      "#E95420"),
    "debian":      ("\uf306",     "Debian",      "#A81D33"),
    "fedora":      ("\uf30a",     "Fedora",      "#51A2DA"),
    "arch":        ("\uf303",     "Arch Linux",  "#1793D1"),
    "manjaro":     ("\uf312",     "Manjaro",     "#35BF5C"),
    "gentoo":      ("\ue7e6",     "Gentoo",      "#b7b2d1"),
    "opensuse":    ("\uf314",     "openSUSE",    "#73BA25"),
    "alpine":      ("\uf300",     "Alpine",      "#0D597F"),
    "void":        ("\uf32e",     "Void Linux",  "#478061"),
    "endeavouros": ("\uf322",     "EndeavourOS", "#7F3FBF"),
}
FALLBACK = ("\uf17c", "Linux", "#cdd6f4")


def main() -> None:
    try:
        info = platform.freedesktop_os_release()
    except (OSError, AttributeError):
        info = {}

    distro_id = info.get("ID", "").lower()
    glyph, name, color = DISTROS.get(distro_id, FALLBACK)

    version = info.get("VERSION_ID") or info.get("VERSION", "")
    kernel = platform.release()

    tooltip = f"{name} {version}\nKernel {kernel}".strip()
    text = f'<span font="Symbols Nerd Font Mono" color="{color}">{glyph}</span>'

    print(json.dumps({"text": text, "tooltip": tooltip}, ensure_ascii=False))


if __name__ == "__main__":
    main()
