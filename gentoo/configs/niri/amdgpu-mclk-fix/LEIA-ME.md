# Fix permanente: flicker 4K@240Hz após hibernação

## O problema

O script atual `/etc/local.d/amdgpu-perf.start` só roda **no boot** (serviço `local`
do OpenRC). Ao acordar da hibernação (S4), o amdgpu reinicializa a GPU e o firmware
SMU do zero, e o nível de performance forçado **não é restaurado de forma confiável**
— o MCLK volta a cair no idle e o flicker retorna. Por isso o bug só reaparece após
hibernar, e "às vezes".

## A solução

O sistema usa OpenRC + elogind, e hooks em `/lib/elogind/system-sleep/` rodam após
todo resume (o hook `aic8800-resume` do adaptador Wi-Fi já usa esse mecanismo).
O fix instala:

1. **`/usr/local/sbin/amdgpu-pin-mclk`** — script que localiza a GPU amdgpu, faz
   `auto` → `manual` em `power_dpm_force_performance_level` e trava o índice mais
   alto do `pp_dpm_mclk` (3 = 1124 MHz), deixando o SCLK escalar livre. Tem retry
   de até 10s porque logo após o resume o SMU pode rejeitar escritas (EBUSY) —
   provável causa do fix falhar "às vezes". Loga em `/var/log/amdgpu-pin-mclk.log`.
2. **`/lib/elogind/system-sleep/amdgpu-mclk`** — hook que roda o script acima em
   background após todo resume (suspend e hibernate).
3. **`/etc/local.d/amdgpu-perf.start`** — substituído: em vez de `echo high`,
   chama o script (método `manual`+mclk, que foi o validado como confiável e
   esquenta menos que `high`).

## Como instalar

```sh
cd ~/.config/niri/amdgpu-mclk-fix
sudo sh install.sh
```

O instalador já aplica o fix imediatamente e imprime o estado da GPU no final.

## O que conferir na saída do instalador

- `power_dpm_force_performance_level: manual`
- `pp_dpm_mclk` com `*` na linha `3: 1124Mhz`
- `pp_dpm_sclk` livre (pode estar em 500Mhz no idle — é o esperado)
- Última linha do log começando com `OK: mclk pinned to index 3`

## Teste do ciclo completo

```sh
loginctl hibernate
# ...acordar a máquina...
cat /sys/class/drm/card0/device/pp_dpm_mclk        # '*' deve estar em 3: 1124Mhz
tail /var/log/amdgpu-pin-mclk.log                   # deve ter entrada nova do resume
```

Depois, o teste real: hibernação longa com bastante memória em uso, e conferir se o
flicker não volta. Se voltar **com o log confirmando o mclk travado**, a causa é
outra (ex.: link training do DP pós-resume) e precisa de investigação separada.

## Reverter

```sh
sudo sh -c 'echo auto > /sys/class/drm/card0/device/power_dpm_force_performance_level'
sudo rm /usr/local/sbin/amdgpu-pin-mclk /lib/elogind/system-sleep/amdgpu-mclk
# e restaurar o conteúdo antigo de /etc/local.d/amdgpu-perf.start se quiser
```

Depois de rodar, me passe a saída do instalador (e depois do teste de hibernação,
a saída dos comandos de verificação) para eu confirmar que está tudo certo.
