#!/usr/bin/env bash
# unsqueeze-fan.sh — binary fan hysteresis daemon.
# Package temp >= FAN_ON: fan FULL speed (kernel WMI, plus EC SPIN bonus).
# Package temp <= FAN_OFF: back to EC auto (quiet).
# The wide deadband (FAN_ON - FAN_OFF = 10C) guarantees no toggling around
# the boundary: once full, it stays full until the temp drops well below.
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

[ -r "$CONF" ] && . "$CONF"

state=auto
hot_count=0

[ "$FAN_ENABLED" = "1" ] || { echo "unsqueeze-fan: disabled in $CONF"; exit 0; }

for i in $(seq 1 20); do
    [ -r "$TEMP" ] && break
    sleep 1
done
[ -r "$TEMP" ] || { echo "unsqueeze-fan: no temp source" >&2; exit 1; }

# Without a writable pwm node every fan write would silently no-op while
# the daemon still reports "full".  Fail fast instead (Restart=always
# retries if the node only appears late).
for i in $(seq 1 20); do
    [ -w "$PWM" ] && break
    sleep 1
done
[ -w "$PWM" ] || { echo "unsqueeze-fan: no writable pwm node ($PWM)" >&2; exit 1; }

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
    # Delta filter: a reading jumping more than 25C within one 5s poll is
    # physically impossible (a laptop heatsink ramps ~2C/s at most). Wake/
    # resume sensor garbage does exactly this — ignore it, keep the last
    # sane reading.
    if [ -n "$t_prev" ]; then
        d=$(( t - t_prev )); [ "$d" -lt 0 ] && d=$(( -d ))
        if [ "$d" -gt 25 ]; then
            sleep "$POLL"
            continue
        fi
    fi
    t_prev=$t

    if [ "$state" = "auto" ]; then
        if [ "$t" -ge "$FAN_ON" ]; then
            # Debounce: require 3 consecutive hot polls (~15s) before going
            # full. Wake spikes can last a few polls; real heat lasts
            # minutes, so the delay is invisible.
            hot_count=$((hot_count + 1))
            if [ "$hot_count" -ge 3 ]; then
                fan_full
                state=full
                echo "unsqueeze-fan: full (${t}C)"
            fi
        else
            hot_count=0
        fi
    elif [ "$state" = "full" ] && [ "$t" -le "$FAN_OFF" ]; then
        fan_auto
        state=auto
        echo "unsqueeze-fan: auto (${t}C)"
    fi
    sleep "$POLL"
done
