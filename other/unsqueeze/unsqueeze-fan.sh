#!/usr/bin/env bash
# unsqueeze-fan.sh — binary fan hysteresis daemon.
# Package temp >= FAN_ON: fan FULL speed (kernel WMI, plus EC SPIN bonus).
# Package temp <= FAN_OFF: back to EC auto (quiet).
# The wide deadband (FAN_ON - FAN_OFF = 10C) guarantees no toggling around
# the boundary: once full, it stays full until the temp drops well below.
# Polls every POLL seconds; only writes on state change.
set -u

# Thermal zone / hwmon numbers are NOT stable on this platform: a late-
# registering zone (e.g. iwlwifi) shifts every subsequent zone by one, so a
# hardcoded thermal_zone12 silently starts reading the wifi temp while the
# CPU bakes. Resolve both sources by name at startup instead.
TEMP_SRC=x86_pkg_temp
PWM_HW=asus
TEMP=""
PWM=""
ACPI_CALL=/proc/acpi/call
CONF=/etc/unsqueeze.conf

FAN_ON=85
FAN_OFF=75
FAN_ENABLED=1
POLL=5

[ -r "$CONF" ] && . "$CONF"

state=auto
hot_count=0
cool_count=0
r1=0; r2=0; r3=0  # raw reading history (median filter)

# median3 A B C — median of three integers.
median3() {
    local a=$1 b=$2 c=$3 hi lo
    if [ "$a" -gt "$b" ]; then hi=$a; lo=$b; else hi=$b; lo=$a; fi
    if   [ "$c" -gt "$hi" ]; then printf '%s' "$hi"
    elif [ "$c" -lt "$lo" ]; then printf '%s' "$lo"
    else printf '%s' "$c"; fi
}

[ "$FAN_ENABLED" = "1" ] || { echo "unsqueeze-fan: disabled in $CONF"; exit 0; }

# Resolve the temp zone whose type matches TEMP_SRC.
resolve_temp() {
    for z in /sys/class/thermal/thermal_zone*; do
        if [ "$(cat "$z/type" 2>/dev/null)" = "$TEMP_SRC" ]; then
            TEMP="$z/temp"
            return 0
        fi
    done
    return 1
}

# Resolve the hwmon dir whose name matches PWM_HW, then point at pwm1_enable.
resolve_pwm() {
    for d in /sys/class/hwmon/hwmon*; do
        if [ "$(cat "$d/name" 2>/dev/null)" = "$PWM_HW" ]; then
            PWM="$d/pwm1_enable"
            return 0
        fi
    done
    return 1
}

# Zones/hwmons may register late at boot; retry before failing.
for i in $(seq 1 30); do
    resolve_temp && break
    sleep 1
done
[ -r "$TEMP" ] || { echo "unsqueeze-fan: temp zone '$TEMP_SRC' not found" >&2; exit 1; }

# Without a writable pwm node every fan write would silently no-op while
# the daemon still reports "full".  Fail fast instead (Restart=always
# retries if the node only appears late).
for i in $(seq 1 30); do
    resolve_pwm && break
    sleep 1
done
[ -w "$PWM" ] || { echo "unsqueeze-fan: writable pwm for '$PWM_HW' not found" >&2; exit 1; }

echo "unsqueeze-fan: temp=$TEMP pwm=$PWM"

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

# Take ownership of the fan at start: if we begin in the auto state, make
# sure the EC auto curve is actually engaged (clears any leftover manual
# full-speed override, e.g. from a manual pwm1_enable=0).
if [ "$state" = "auto" ]; then
    fan_auto
fi

while true; do
    raw=$(( $(cat "$TEMP" 2>/dev/null || echo 0) / 1000 ))
    # Median-of-3: the package sensor can read transient outliers (wake
    # spikes, background bursts). The median of the last 3 reads ignores a
    # single outlier while real heat moves monotonically.
    r3=$r2; r2=$r1; r1=$raw
    if [ "$r3" -eq 0 ] || [ "$r2" -eq 0 ]; then
        t=$raw
    else
        t=$(median3 "$r1" "$r2" "$r3")
    fi

    if [ "$state" = "auto" ]; then
        if [ "$t" -ge "$FAN_ON" ]; then
            # Leaky debounce: hot polls accumulate, a single cool blip only
            # decrements. 2 hot polls (~10s) trigger so the fan beats short
            # loads; alternating sensor garbage can't reach 2.
            hot_count=$((hot_count + 1))
            if [ "$hot_count" -ge 2 ]; then
                fan_full
                state=full
                echo "unsqueeze-fan: full (${t}C)"
            fi
        elif [ "$hot_count" -gt 0 ]; then
            hot_count=$((hot_count - 1))
        fi
    elif [ "$state" = "full" ]; then
        if [ "$t" -le "$FAN_OFF" ]; then
            # Leaky release: require 2 cool polls so one noise blip doesn't
            # drop the fan mid-load.
            cool_count=$((cool_count + 1))
            if [ "$cool_count" -ge 2 ]; then
                fan_auto
                state=auto
                echo "unsqueeze-fan: auto (${t}C)"
            fi
        else
            cool_count=0
        fi
    fi
    sleep "$POLL"
done
