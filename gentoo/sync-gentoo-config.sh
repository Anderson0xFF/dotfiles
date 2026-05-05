#!/bin/sh
# Sincroniza estado do Gentoo + dotfiles selecionados para ~/dotfiles/gentoo.
# Roda de hora em hora via cron (ver crontab no fim deste arquivo como comentário).

set -eu

DEST="${HOME}/dotfiles/gentoo"
CONFIGS="${DEST}/configs"

mkdir -p "${DEST}" "${CONFIGS}"

# 1. Lista de pacotes do @world com versão e overlay. Cruza /var/lib/portage/world
#    (sem versão) com qlist -IRCv (todos instalados, com versão+overlay).
#    Resultado: cat/pkg-version::overlay — só pacotes que VOCÊ pediu pra instalar.
qlist -IRCv | awk 'NR==FNR{w[$0]=1; next} {n=$1; sub(/-[0-9].*/,"",n); if (n in w) print}' \
    /var/lib/portage/world - > "${DEST}/gentoo-packages.txt"

# 2. World file cru (sem versão) — é o que o portage usa pra reinstalar via @world.
cp /var/lib/portage/world "${DEST}/world"

# 3. Serviços OpenRC e seus runlevels.
rc-update show -v > "${DEST}/openrc-services.txt"

# 4. Overlays habilitados.
#    eselect repository list -i pode tentar baixar repositories.xml; usar
#    --offline-equivalent: lendo direto de repos.conf é mais confiável e rápido.
{
    echo "# Overlays configurados em /etc/portage/repos.conf/"
    echo
    grep -h '^\[' /etc/portage/repos.conf/*.conf 2>/dev/null | sort -u
    echo
    echo "# Detalhe (location, sync-uri):"
    echo
    for f in /etc/portage/repos.conf/*.conf; do
        [ -f "${f}" ] || continue
        echo "## $(basename "${f}")"
        cat "${f}"
        echo
    done
} > "${DEST}/overlays.txt"

# 5. Profile.
eselect profile show > "${DEST}/profile.txt" 2>&1 || true

# 6. /etc/portage/ — make.conf, package.use, package.accept_keywords,
#    package.mask, repos.conf, savedconfig, etc. Crítico pra reinstalar:
#    sem isso suas USE flags por pacote e keywords aceitos se perdem.
#    EXCLUI gnupg/ (chaves privadas — não devem ir pra dotfiles).
ETCDEST="${DEST}/portage"
rm -rf "${ETCDEST}"
mkdir -p "${ETCDEST}"
rsync -a --exclude=gnupg /etc/portage/ "${ETCDEST}/" 2>/dev/null || \
    cp -a /etc/portage/* "${ETCDEST}/" 2>/dev/null

# 7. Dotfiles selecionados.
copy_config() {
    src="$1"
    name="$2"
    if [ -e "${HOME}/.config/${src}" ]; then
        rm -rf "${CONFIGS:?}/${name}"
        cp -a "${HOME}/.config/${src}" "${CONFIGS}/${name}"
    fi
}

copy_config niri                niri
copy_config waybar              waybar
copy_config xdg-desktop-portal  xdg-desktop-portal
copy_config ghostty             ghostty
copy_config walker              walker
copy_config qt5ct               qt5ct
copy_config qt6ct               qt6ct
copy_config mako                mako

# starship é arquivo solto em ~/.config/starship.toml
if [ -f "${HOME}/.config/starship.toml" ]; then
    cp -a "${HOME}/.config/starship.toml" "${CONFIGS}/starship.toml"
fi

# swayidle e swaylock (você mencionou "sway*")
copy_config swayidle            swayidle
copy_config swaylock            swaylock

# Timestamp da última sincronização.
date '+%Y-%m-%d %H:%M:%S %Z' > "${DEST}/.last-sync"

# Crontab sugerida (rodar manualmente uma vez):
#   crontab -e
#   0 * * * * /home/alynx/dotfiles/gentoo/sync-gentoo-config.sh >/dev/null 2>&1
