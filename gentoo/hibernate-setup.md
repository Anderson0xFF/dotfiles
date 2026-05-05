# Hibernação no Gentoo (loginctl hibernate)

Como configurar hibernação (suspend-to-disk) neste sistema. Setup de referência: GRUB + dracut + installkernel-gentoo, root em btrfs, swap em partição dedicada, kernel da árvore (`sys-kernel/gentoo-kernel-bin`).

## Pré-requisitos

- Kernel com `CONFIG_HIBERNATION=y`. Verificar com `zgrep HIBERNATION /proc/config.gz` ou `grep HIBERNATION /boot/config-$(uname -r)`. `/sys/power/disk` deve listar pelo menos `[platform]` ou `shutdown`.
- Swap com tamanho >= RAM (ou pelo menos do tamanho da memória ativa esperada na hora da hibernação). `swapon --show` para conferir.
- `sys-fs/btrfs-progs` instalado (sem ele, o dracut gera initramfs sem o binário `btrfs` e o boot quebra). Pacote crítico em qualquer regeneração de initramfs.

## Passos

### 1. Adicionar `resume=` ao cmdline do kernel via GRUB

Editar [/etc/default/grub](/etc/default/grub):

```
GRUB_CMDLINE_LINUX="resume=UUID=<UUID-da-swap>"
```

Pegar o UUID da swap com `lsblk -o NAME,FSTYPE,UUID` ou `blkid`. Usar UUID em vez de `/dev/nvmeXnYpZ` para sobreviver a remapeamentos.

### 2. Habilitar o módulo `resume` do dracut

Sem isso o initramfs **não escreve** o major:minor da swap em `/sys/power/resume` durante o boot e a hibernação falha silenciosamente (kernel recebe `resume=UUID=…` mas não consegue resolver). Sintoma típico: `cat /sys/power/resume` retorna `0:0` mesmo com o `resume=` em `/proc/cmdline`.

Criar [/etc/dracut.conf.d/10-resume.conf](/etc/dracut.conf.d/10-resume.conf):

```
add_dracutmodules+=" resume "
```

Os espaços antes/depois de `resume` são parte da sintaxe.

Para escrever como root via shell sem cair no erro de redirecionamento (`sudo echo > /etc/...` falha porque o `>` é feito pelo shell do usuário antes do sudo):

```
echo 'add_dracutmodules+=" resume "' | sudo tee /etc/dracut.conf.d/10-resume.conf
```

### 3. Regenerar initramfs e grub.cfg

```
sudo installkernel
```

O `sys-kernel/installkernel` (com USE `dracut` e `grub`) tem hooks em `/usr/lib/kernel/install.d/` que disparam `dracut --force` e `grub-mkconfig` automaticamente:

- `52-dracut.install` regenera o initramfs
- `91-grub-mkconfig.install` regenera `/boot/grub/grub.cfg`

Alternativamente: `sudo emerge --config sys-kernel/gentoo-kernel-bin` invoca o mesmo pipeline.

### 4. Verificar antes de reiniciar

```
sudo grep -nE 'linux\s+/(boot/)?vmlinuz' /boot/grub/grub.cfg | head -3
```
Cada entrada deve terminar com `… ro resume=UUID=<UUID-da-swap>`.

```
lsinitrd /boot/initramfs-$(uname -r).img | grep -iE 'parse-resume|resume\.sh'
```
Esperado:
```
usr/lib/dracut/resume.sh
var/lib/dracut/hooks/cmdline/10-parse-resume.sh
```

### 5. Reiniciar e testar

Após o boot:

```
cat /proc/cmdline                       # deve conter resume=UUID=…
cat /sys/power/resume                   # deve mostrar major:minor (ex: 259:2), NÃO 0:0
busctl call org.freedesktop.login1 /org/freedesktop/login1 \
    org.freedesktop.login1.Manager CanHibernate
# esperado: s "yes"
```

Teste real:
```
loginctl hibernate
```
Máquina desliga (LEDs/fans off). Religar restaura a sessão.

## Por que cada peça importa

- **`resume=` no `/etc/default/grub`** (não no `kernel_cmdline` do dracut): o `installkernel-gentoo` **não** propaga o `kernel_cmdline` do dracut para o GRUB. Aquela chave só é embutida dentro do initramfs (vista por `lsinitrd`), e o GRUB pega o cmdline de `GRUB_CMDLINE_LINUX`. Setups com UKI são diferentes.
- **Módulo `resume` do dracut**: contém `parse-resume.sh` (parseia `resume=UUID=…` do cmdline) e `resume.sh` (escreve `major:minor` em `/sys/power/resume` antes do switch_root). Sem ele, o kernel não sabe de onde retomar.
- **Swap em partição** (não swapfile): caminho mais simples no btrfs. Swapfile em btrfs precisaria de `resume_offset=` calculado por `btrfs inspect-internal map-swapfile -r <swapfile>` e o swapfile precisaria estar em subvolume sem CoW.

## Integração com swayidle

Em [/home/alynx/.config/swayidle/config](/home/alynx/.config/swayidle/config):

```
timeout 1800 'pidof -x swaylock || loginctl hibernate'
```

O `pidof -x swaylock ||` impede instâncias duplicadas do swaylock. O lock é disparado antes da hibernação, então ao retomar a tela já está bloqueada — daí a impressão (quando hibernação está quebrada) de que o swayidle "só travou a tela".

## Ao atualizar o kernel

`emerge sys-kernel/gentoo-kernel-bin` (ou equivalente) re-roda os hooks do `installkernel`, então o initramfs novo vai automaticamente incluir o módulo `resume` (porque `10-resume.conf` é persistente) e o `grub.cfg` vai automaticamente incluir o `resume=` (porque `/etc/default/grub` é persistente). Nada a refazer.

## Sintomas de configuração quebrada

| Sintoma | Causa provável |
|---|---|
| `cat /sys/power/resume` retorna `0:0` mesmo com `resume=` em `/proc/cmdline` | Módulo `resume` do dracut ausente do initramfs |
| `resume=` não aparece em `/proc/cmdline` mesmo após editar `/etc/default/grub` | `grub-mkconfig` não foi rodado, ou foi rodado antes da edição |
| `busctl ... CanHibernate` retorna `"no"` | Swap insuficiente, ou systemd-logind não detecta swap, ou hibernação desabilitada no kernel |
| Boot falha após regenerar initramfs com erro mencionando btrfs | `sys-fs/btrfs-progs` não instalado quando o initramfs foi regerado |
| `dracut[E]: i18n_vars not set!` | Cosmético, ignorar (ou definir `i18n_vars` em `/etc/dracut.conf.d/`) |

## Arquivos relevantes neste sistema

- [/etc/default/grub](/etc/default/grub)
- [/etc/dracut.conf.d/00-installkernel.conf](/etc/dracut.conf.d/00-installkernel.conf) — `kernel_cmdline` (controla apenas o initramfs, não o GRUB)
- [/etc/dracut.conf.d/10-resume.conf](/etc/dracut.conf.d/10-resume.conf) — habilita o módulo `resume`
- [/etc/fstab](/etc/fstab) — entrada da swap
- [/usr/lib/kernel/install.d/52-dracut.install](/usr/lib/kernel/install.d/52-dracut.install) — hook do `installkernel`
- [/usr/lib/kernel/install.d/91-grub-mkconfig.install](/usr/lib/kernel/install.d/91-grub-mkconfig.install) — hook do `installkernel`
- [/usr/lib/dracut/modules.d/74resume/](/usr/lib/dracut/modules.d/74resume/) — fonte do módulo dracut
