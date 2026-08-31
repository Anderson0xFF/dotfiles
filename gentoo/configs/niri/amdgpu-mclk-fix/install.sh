#!/bin/sh
#
# Instalador do fix permanente do flicker 4K@240Hz (pin do MCLK da amdgpu).
# Execute como root:  sudo sh install.sh
#
# Instala 3 arquivos:
#   /usr/local/sbin/amdgpu-pin-mclk          - script que trava o MCLK no estado máximo
#   /lib/elogind/system-sleep/amdgpu-mclk    - hook que reaplica após todo resume (S3/S4)
#   /etc/local.d/amdgpu-perf.start           - substitui o script de boot atual (echo high)
#
# Ao final, roda o script uma vez e mostra o estado da GPU.

set -e

if [ "$(id -u)" != 0 ]; then
    echo "Execute como root: sudo sh $0" >&2
    exit 1
fi

# ------------------------------------------------------------------
# 1. /usr/local/sbin/amdgpu-pin-mclk
# ------------------------------------------------------------------
cat > /usr/local/sbin/amdgpu-pin-mclk << 'EOF'
#!/bin/sh
#
# Pin the amdgpu memory clock (MCLK) to its highest DPM state.
#
# The RX 6700 XT driving a 4K@240Hz display over DP 1.4a+DSC flickers
# whenever the SMU drops MCLK to a low idle state — the memory can no
# longer sustain the scanout bandwidth. Forcing "manual" mode and
# selecting only the highest pp_dpm_mclk index pins the memory clock
# while leaving SCLK free to scale.
#
# Called from:
#   /etc/local.d/amdgpu-perf.start          (boot)
#   /lib/elogind/system-sleep/amdgpu-mclk   (post-resume)
#
# Right after resume from S3/S4 the SMU may still be re-initialising
# and reject sysfs writes (EBUSY), so every write is retried.

LOG=/var/log/amdgpu-pin-mclk.log
RETRIES=10

log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') $*" >> "$LOG"
}

# Locate the amdgpu card (robust against card renumbering).
dev=
for d in /sys/class/drm/card*/device; do
    if grep -q '^DRIVER=amdgpu$' "$d/uevent" 2>/dev/null; then
        dev=$d
        break
    fi
done

if [ -z "$dev" ]; then
    log "ERROR: no amdgpu device found"
    exit 1
fi

# Retry a sysfs write until it sticks.
write_retry() {
    # $1 = value, $2 = file
    i=0
    while [ $i -lt $RETRIES ]; do
        if echo "$1" > "$2" 2>/dev/null; then
            return 0
        fi
        i=$((i + 1))
        sleep 1
    done
    log "ERROR: failed to write '$1' to $2 after $RETRIES attempts"
    return 1
}

# Highest MCLK index = last line of pp_dpm_mclk.
max_idx=$(sed -n '$s/^\([0-9][0-9]*\):.*/\1/p' "$dev/pp_dpm_mclk")
if [ -z "$max_idx" ]; then
    log "ERROR: could not parse $dev/pp_dpm_mclk"
    exit 1
fi

# Toggle through auto first to clear any stale forced state in the SMU,
# then take manual control of the MCLK mask only.
write_retry auto "$dev/power_dpm_force_performance_level" || exit 1
write_retry manual "$dev/power_dpm_force_performance_level" || exit 1
write_retry "$max_idx" "$dev/pp_dpm_mclk" || exit 1

# Confirm the highest state is active ('*' on its line).
if grep -q "^${max_idx}:.*\*" "$dev/pp_dpm_mclk"; then
    log "OK: mclk pinned to index $max_idx on $dev ($(grep "^${max_idx}:" "$dev/pp_dpm_mclk"))"
else
    log "WARNING: wrote index $max_idx but '*' not on highest state: $(tr '\n' ' ' < "$dev/pp_dpm_mclk")"
fi

exit 0
EOF
chmod 0755 /usr/local/sbin/amdgpu-pin-mclk
echo "instalado: /usr/local/sbin/amdgpu-pin-mclk"

# ------------------------------------------------------------------
# 2. /lib/elogind/system-sleep/amdgpu-mclk
# ------------------------------------------------------------------
cat > /lib/elogind/system-sleep/amdgpu-mclk << 'EOF'
#!/bin/sh
#
# elogind/systemd system-sleep hook: re-pin the amdgpu MCLK after resume.
#
# On resume from S3/S4 the amdgpu driver re-initialises the SMU and the
# forced DPM state is not reliably restored — the MCLK starts scaling
# down again and the 4K@240Hz DP1.4a+DSC signal flickers. Re-apply the
# pin on every wake-up.
#
# Hook contract (elogind, identical to systemd):
#   $1 = "pre"  or "post"
#   $2 = "suspend" / "hibernate" / "hybrid-sleep" / "suspend-then-hibernate"

case "$1/$2" in
    post/*)
        # Detach fully: the script retries for up to ~10s while the SMU
        # settles, and wakeup completion must not wait on that.
        if [ -x /usr/local/sbin/amdgpu-pin-mclk ]; then
            (/usr/local/sbin/amdgpu-pin-mclk &) </dev/null
        fi
        ;;
esac

exit 0
EOF
chmod 0755 /lib/elogind/system-sleep/amdgpu-mclk
echo "instalado: /lib/elogind/system-sleep/amdgpu-mclk"

# ------------------------------------------------------------------
# 3. /etc/local.d/amdgpu-perf.start (substitui o 'echo high' atual)
# ------------------------------------------------------------------
cat > /etc/local.d/amdgpu-perf.start << 'EOF'
#!/bin/sh
#
# Boot-time application of the amdgpu MCLK pin (see the script itself
# for the why). Re-applied after every resume by
# /lib/elogind/system-sleep/amdgpu-mclk.

/usr/local/sbin/amdgpu-pin-mclk
EOF
chmod 0755 /etc/local.d/amdgpu-perf.start
echo "instalado: /etc/local.d/amdgpu-perf.start"

# ------------------------------------------------------------------
# Aplica agora e mostra o resultado
# ------------------------------------------------------------------
echo
echo "== Aplicando agora =="
/usr/local/sbin/amdgpu-pin-mclk

dev=$(for d in /sys/class/drm/card*/device; do
    grep -q '^DRIVER=amdgpu$' "$d/uevent" 2>/dev/null && echo "$d" && break
done)

echo
echo "== Estado atual =="
echo "power_dpm_force_performance_level: $(cat "$dev/power_dpm_force_performance_level")"
echo "pp_dpm_mclk:"
cat "$dev/pp_dpm_mclk"
echo "pp_dpm_sclk:"
cat "$dev/pp_dpm_sclk"
echo
echo "== Log =="
tail -3 /var/log/amdgpu-pin-mclk.log
echo
echo "Instalacao concluida."
