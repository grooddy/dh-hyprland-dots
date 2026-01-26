#!/usr/bin/env bash

MONITOR="eDP-1"
LOW_HZ=60
HIGH_HZ=144

if [ -n "$HYPRLAND_INSTANCE_SIGNATURE" ]; then
    RAW_HZ=$(hyprctl monitors -j | jq -r ".[] | select(.name == \"$MONITOR\") | .refreshRate" 2>/dev/null)

    if [ -z "$RAW_HZ" ]; then
        notify-send -u critical "Error" "Failed to get refresh rate"
        exit 1
    fi

    CURRENT_HZ=$(echo "$RAW_HZ" | awk '{print int($1)}')

    if [ "$CURRENT_HZ" -le "$LOW_HZ" ]; then
        # PERFORMANCE MODE
        NEW_HZ=$HIGH_HZ
        # Выполняем смену герцовки и эффектов одной пачкой
        hyprctl --batch "keyword monitor $MONITOR, 1920x1080@$HIGH_HZ, 0x0, 1; \
                         keyword animations:enabled true; \
                         keyword decoration:shadow:enabled true; \
                         keyword decoration:blur:enabled true"

        ICON="preferences-desktop-display"
        MSG="Performance Mode: ${NEW_HZ}Hz + FX"
    else
        # POWER SAVE MODE
        NEW_HZ=$LOW_HZ
        hyprctl --batch "keyword monitor $MONITOR, 1920x1080@60, 0x0, 1; \
                         keyword animations:enabled false; \
                         keyword decoration:shadow:enabled false; \
                         keyword decoration:blur:enabled false"

        ICON="battery-low"
        MSG="Power Save Mode: ${NEW_HZ}Hz (No FX)"
    fi
fi

notify-send -a "System" -i "$ICON" "Display Settings" "$MSG"
