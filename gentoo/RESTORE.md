# Restaurar Gentoo

Após bootar com Gentoo base do handbook (kernel, rede, sudo
funcionando), copiar esta pasta para `~/dotfiles/gentoo/` e:

```sh
cd ~/dotfiles/gentoo

# 1. Profile
sudo eselect profile set "$(awk -F'  ' '/symlink:/{getline; print $2}' profile.txt)"

# 2. /etc/portage (make.conf, USE flags, keywords, repos.conf)
sudo mv /etc/portage /etc/portage.bak
sudo cp -r portage /etc/portage
sudo getuto                                    # regenera /etc/portage/gnupg/

# 3. Overlays
sudo emerge --ask app-eselect/eselect-repository
sudo eselect repository enable guru pf4public
sudo emaint sync -A

# 4. World
sudo cp world /var/lib/portage/world
sudo emerge --ask --update --deep --newuse @world

# 5. Serviços OpenRC (ver openrc-services.txt — coluna direita = runlevel)
for s in NetworkManager chronyd cronie dbus docker libvirtd \
         netmount sysklogd vmware local; do
    sudo rc-update add "$s" default
done

# 6. Dotfiles
cp -r configs/. ~/.config/

# 7. Grupos do usuário
for g in wheel audio video docker libvirt kvm plugdev; do
    sudo gpasswd -a "$USER" "$g"
done

sudo reboot
```

## Não está aqui (backup separado)

- Chaves SSH (`~/.ssh/`), GPG (`~/.gnupg/`), portage (`/etc/portage/gnupg/`)
- Crontab do usuário (`crontab -l`)
- `~/.zshrc` e companhia

## Conteúdo da pasta

| Arquivo | O que é |
|---|---|
| `world` | `/var/lib/portage/world` — pra `emerge @world` |
| `portage/` | `/etc/portage/` sem `gnupg/` |
| `configs/` | dotfiles de `~/.config/` (niri, waybar, ghostty, etc.) |
| `gentoo-packages.txt` | pacotes com versão+overlay (referência humana) |
| `openrc-services.txt` | `rc-update show -v` |
| `overlays.txt` | `repos.conf` resumido |
| `profile.txt` | `eselect profile show` |
| `sync-gentoo-config.sh` | regenera tudo (cron de 1h) |
| `.last-sync` | timestamp da última sync |
