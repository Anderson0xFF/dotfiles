# Guia de Instalação do Gentoo Linux

Setup: OpenRC | GRUB | EFI | Wayland | PipeWire | GTK

---

## 1. Preparar o Live CD

Baixe a ISO minimal do Gentoo e boote em modo **EFI**.

Verifique se está em EFI:

```bash
ls /sys/firmware/efi
```

Se o diretório existir, está em EFI.

---

## 2. Rede

```bash
# Verificar conexão
ping -c 3 google.com

# Se precisar de WiFi
net-setup wlan0
```

---

## 3. Particionamento

```bash
fdisk /dev/sda
```

| Partição   | Tipo             | Tamanho  | Formato |
|------------|------------------|----------|---------|
| /dev/sda1  | EFI System (ef00)| 512M     | FAT32   |
| /dev/sda2  | Linux swap (8200)| 4G       | swap    |
| /dev/sda3  | Linux (8300)     | Restante | ext4    |

```bash
mkfs.fat -F32 /dev/sda1
mkswap /dev/sda2
swapon /dev/sda2
mkfs.ext4 /dev/sda3
```

---

## 4. Montar partições

```bash
mount /dev/sda3 /mnt/gentoo
mkdir -p /mnt/gentoo/efi
mount /dev/sda1 /mnt/gentoo/efi
```

---

## 5. Stage3

```bash
cd /mnt/gentoo

# Baixar stage3 (OpenRC)
links https://www.gentoo.org/downloads/

# Extrair
tar xpvf stage3-*.tar.xz --xattrs-include='*.*' --numeric-owner
```

---

## 6. make.conf

```bash
nano /mnt/gentoo/etc/portage/make.conf
```

Adicionar/ajustar:

```bash
COMMON_FLAGS="-march=native -O2 -pipe"

# Número de jobs = número de cores
MAKEOPTS="-j$(nproc)"

# USE flags
USE="-X -qt5 -qt6 -kde -dvd -cdr -pulseaudio dist-kernel"

# GPU
VIDEO_CARDS="vmware"
# Para AMD:     VIDEO_CARDS="amdgpu radeonsi"
# Para NVIDIA:  VIDEO_CARDS="nvidia"
# Para Intel:   VIDEO_CARDS="intel"

# Aceitar licenças
ACCEPT_LICENSE="*"
```

> **Nota:** flags como `wayland`, `gtk`, `alsa`, `dbus`, `pipewire`, `elogind`,
> `vulkan`, `opengl` já vêm habilitadas pelo profile `desktop`.
> Verifique com: `emerge --info | grep ^USE`

---

## 7. Repositórios e DNS

```bash
mkdir -p /mnt/gentoo/etc/portage/repos.conf
cp /mnt/gentoo/usr/share/portage/config/repos.conf \
   /mnt/gentoo/etc/portage/repos.conf/gentoo.conf

cp --dereference /etc/resolv.conf /mnt/gentoo/etc/
```

---

## 8. Chroot

```bash
mount --types proc /proc /mnt/gentoo/proc
mount --rbind /sys /mnt/gentoo/sys
mount --rbind /dev /mnt/gentoo/dev

chroot /mnt/gentoo /bin/bash
source /etc/profile
export PS1="(chroot) $PS1"
```

---

## 9. Sincronizar repositório e escolher profile

```bash
emerge-webrsync
eselect profile list
eselect profile set <número do profile desktop>
```

---

## 10. Timezone e Locale

```bash
# Timezone
echo "America/Sao_Paulo" > /etc/timezone
emerge --config sys-libs/timezone-data

# Locale
echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
echo "pt_BR.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen

eselect locale list
eselect locale set <número>
env-update && source /etc/profile
```

---

## 11. Kernel

```bash
# Configurar installkernel com GRUB + dracut
echo "sys-kernel/installkernel grub dracut" > /etc/portage/package.use/installkernel
emerge --ask sys-kernel/installkernel

# Configurar dracut com UUID da partição root
mkdir -p /etc/dracut.conf.d
echo "kernel_cmdline=\" root=UUID=$(blkid -s UUID -o value /dev/sda3) \"" > /etc/dracut.conf.d/00-installkernel.conf

# Instalar kernel binário
emerge --ask sys-kernel/gentoo-kernel-bin
```

---

## 12. Fstab

```bash
# Gerar automaticamente
emerge --ask sys-fs/genfstab
genfstab -U / >> /etc/fstab

# Verificar se está correto
cat /etc/fstab
```

> Se `genfstab` não estiver disponível, edite manualmente:

```bash
nano /etc/fstab
```

```
UUID=<uuid-sda1>  /efi   vfat  defaults  0 2
UUID=<uuid-sda2>  none   swap  sw        0 0
UUID=<uuid-sda3>  /      ext4  defaults  0 1
```

Use `blkid` para pegar os UUIDs.

---

## 13. GRUB

```bash
emerge --ask sys-boot/grub
grub-install --target=x86_64-efi --efi-directory=/efi --bootloader-id=Gentoo
grub-mkconfig -o /boot/grub/grub.cfg
```

---

## 14. Configurações finais

```bash
# Hostname
echo "gentoo" > /etc/hostname

# Senha root
passwd

# Rede
emerge --ask net-misc/dhcpcd
rc-update add dhcpcd default

# Criar usuário
useradd -m -G users,wheel,audio,video -s /bin/bash anderson
passwd anderson

# Sudo
emerge --ask app-admin/sudo
echo "%wheel ALL=(ALL:ALL) ALL" >> /etc/sudoers
```

---

## 15. Reboot

```bash
exit
cd
umount -l /mnt/gentoo/dev{/shm,/pts,}
umount -R /mnt/gentoo
reboot
```

Remova o Live CD antes de reiniciar.

---

## 16. Pós-instalação (após reboot)

```bash
# Atualizar @world
emerge --ask --update --deep --newuse @world

# PipeWire
emerge --ask media-video/pipewire media-video/wireplumber

# Niri (via overlay)
# Adicionar o overlay necessário e instalar

# Ferramentas úteis
emerge --ask app-editors/neovim dev-vcs/git
```

---

## Comando rápido para re-entrar no chroot (se precisar)

```bash
mount /dev/sda3 /mnt/gentoo && mount /dev/sda1 /mnt/gentoo/efi && mount --types proc /proc /mnt/gentoo/proc && mount --rbind /sys /mnt/gentoo/sys && mount --rbind /dev /mnt/gentoo/dev && chroot /mnt/gentoo /bin/bash
source /etc/profile
```

---

## Referências

- Handbook: https://wiki.gentoo.org/wiki/Handbook:AMD64
- USE flags: https://wiki.gentoo.org/wiki/USE_flag
- Instalador automático: https://github.com/oddlama/gentoo-install
