#!/usr/bin/env bash
# unsqueeze-power.sh — set the enforced (MMIO/PUNIT) RAPL power limits.
# AC plugged: 45W PL1 / 65W PL2. On battery: 25W PL1 / 45W PL2.
set -u

ZONE=/sys/class/powercap/intel-rapl-mmio:0
CONF=/etc/unsqueeze.conf

PL1_AC=45000000
PL2_AC=65000000
PL1_BAT=25000000
PL2_BAT=45000000

[ -r "$CONF" ] && . "$CONF"

for i in $(seq 1 30); do
    [ -d "$ZONE" ] && break
    sleep 1
done
[ -d "$ZONE" ] || { echo "unsqueeze-power: zone $ZONE not found" >&2; exit 1; }

ac=0
for s in /sys/class/power_supply/AC*/online; do
    [ -r "$s" ] && [ "$(cat "$s" 2>/dev/null)" = "1" ] && ac=1
done

if [ "$ac" = "1" ]; then
    PL1=$PL1_AC; PL2=$PL2_AC
else
    PL1=$PL1_BAT; PL2=$PL2_BAT
fi

for f in "$ZONE"/constraint_*_name; do
    [ -r "$f" ] || continue
    case "$(cat "$f" 2>/dev/null)" in
        long_term)
            echo "$PL1" > "${f%_name}_power_limit_uw" 2>/dev/null || true
            ;;
        short_term)
            echo "$PL2" > "${f%_name}_power_limit_uw" 2>/dev/null || true
            ;;
    esac
done

echo "unsqueeze-power: PL1=${PL1} PL2=${PL2} (AC=${ac})"
