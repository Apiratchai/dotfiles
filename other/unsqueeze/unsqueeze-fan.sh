#!/usr/bin/env bash
# unsqueeze-fan.sh — binary fan hysteresis daemon.
# Package temp > 78C: fan FULL speed (EC via acpi_call SPIN 1 255, or kernel WMI fallback).
# Package temp < 68C: fan back to EC auto (quiet).
# Polls every 5s; only writes on state change.
set -u

TEMP=/sys/class/thermal/thermal_zone12/temp
PWM=/sys/class/hwmon/hwmon4/pwm1_enable
ACPI_CALL=/proc/acpi/call
CONF=/etc/unsqueeze.conf

FAN_ON=78
FAN_OFF=68
FAN_ENABLED=1
POLL=5

[ -r "$CONF" ] && . "$CONF"

state=auto

[ "$FAN_ENABLED" = "1" ] || { echo "unsqueeze-fan: disabled in $CONF"; exit 0; }

for i in $(seq 1 20); do
    [ -r "$TEMP" ] && break
    sleep 1
done
[ -r "$TEMP" ] || { echo "unsqueeze-fan: no temp source" >&2; exit 1; }

modprobe acpi_call 2>/dev/null || true

fan_full() {
    if [ -w "$ACPI_CALL" ]; then
        echo '\_SB.PC00.LPCB.EC0_.SPIN 1 255' > "$ACPI_CALL" 2>/dev/null
        return
    fi
    echo 0 > "$PWM" 2>/dev/null
}

fan_auto() {
    echo 2 > "$PWM" 2>/dev/null
}

while true; do
    t=$(( $(cat "$TEMP" 2>/dev/null || echo 0) / 1000 ))
    if [ "$state" = "auto" ] && [ "$t" -ge "$FAN_ON" ]; then
        fan_full
        state=full
        echo "unsqueeze-fan: full (${t}C)"
    elif [ "$state" = "full" ] && [ "$t" -le "$FAN_OFF" ]; then
        fan_auto
        state=auto
        echo "unsqueeze-fan: auto (${t}C)"
    fi
    sleep "$POLL"
done
