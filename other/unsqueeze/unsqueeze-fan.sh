#!/usr/bin/env bash
# unsqueeze-fan.sh — binary fan hysteresis daemon.
# Package temp > FAN_ON: fan FULL speed (kernel WMI, plus EC SPIN bonus).
# Package temp < FAN_OFF for at least MIN_FULL_SECONDS: back to EC auto (quiet).
# The time latch prevents rapid full/auto cycling under oscillating loads.
# Polls every POLL seconds; only writes on state change.
set -u

TEMP=/sys/class/thermal/thermal_zone12/temp
PWM=/sys/class/hwmon/hwmon4/pwm1_enable
ACPI_CALL=/proc/acpi/call
CONF=/etc/unsqueeze.conf

FAN_ON=78
FAN_OFF=68
FAN_ENABLED=1
POLL=5
MIN_FULL_SECONDS=120

[ -r "$CONF" ] && . "$CONF"

state=auto
full_since=0

[ "$FAN_ENABLED" = "1" ] || { echo "unsqueeze-fan: disabled in $CONF"; exit 0; }

for i in $(seq 1 20); do
    [ -r "$TEMP" ] && break
    sleep 1
done
[ -r "$TEMP" ] || { echo "unsqueeze-fan: no temp source" >&2; exit 1; }

modprobe acpi_call 2>/dev/null || true

fan_full() {
    # Kernel WMI full-speed is the reliable path (works in every EC state).
    echo 0 > "$PWM" 2>/dev/null
    # Bonus: direct EC override for the extra ~400 RPM, where honored.
    if [ -w "$ACPI_CALL" ]; then
        echo '\_SB.PC00.LPCB.EC0_.SPIN 1 255' > "$ACPI_CALL" 2>/dev/null
    fi
}

fan_auto() {
    echo 2 > "$PWM" 2>/dev/null
}

while true; do
    t=$(( $(cat "$TEMP" 2>/dev/null || echo 0) / 1000 ))
    now=$(date +%s 2>/dev/null || echo 0)
    if [ "$state" = "auto" ] && [ "$t" -ge "$FAN_ON" ]; then
        fan_full
        state=full
        full_since=$now
        echo "unsqueeze-fan: full (${t}C)"
    elif [ "$state" = "full" ] && [ "$t" -le "$FAN_OFF" ] \
        && [ $(( now - full_since )) -ge "$MIN_FULL_SECONDS" ]; then
        fan_auto
        state=auto
        echo "unsqueeze-fan: auto (${t}C)"
    fi
    sleep "$POLL"
done
