#!/usr/bin/env bash

MONITOR="eDP-1"
LOW_HZ=60
HIGH_HZ=144

if [ -n "$HYPRLAND_INSTANCE_SIGNATURE" ]; then
    # Получаем данные
    RAW_HZ=$(hyprctl monitors -j | jq -r ".[] | select(.name == \"$MONITOR\") | .refreshRate" 2>/dev/null)
    
    # Если jq выдал пустоту
    if [ -z "$RAW_HZ" ]; then
        notify-send -u critical "Error" "Failed to get refresh rate (is jq installed?)"
        exit 1
    fi

    # Приводим к целому числу
    CURRENT_HZ=$(echo "$RAW_HZ" | awk '{print int($1)}')

    if [ "$CURRENT_HZ" -le "$LOW_HZ" ]; then
        NEW_HZ=$HIGH_HZ
        hyprctl keyword monitor "$MONITOR, 1920x1080@$HIGH_HZ, 0x0, 1"
    else
        NEW_HZ=$LOW_HZ
        hyprctl keyword monitor "$MONITOR, 1920x1080@60, 0x0, 1"
    fi
# --- ВОТ ЭТОГО НЕ ХВАТАЛО ---
fi 

# Универсальное уведомление
notify-send -a "System" -i "display" "Display Settings" "Refresh rate set to ${NEW_HZ}Hz"
