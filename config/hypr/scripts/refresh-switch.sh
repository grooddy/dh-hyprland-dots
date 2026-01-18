#!/bin/bash

MONITOR="eDP-1"
LOW_HZ=60
HIGH_HZ=144

# 1. Детекция среды и получение текущей герцовки
if [ "$XDG_CURRENT_DESKTOP" = "niri" ]; then
    # Парсим строку "Current mode: 1920x1080 @ 144.000 Hz"
    CURRENT_HZ=$(niri msg outputs | grep "Current mode" | awk '{print $5}' | cut -d'.' -f1)

    # В Niri меняем через подмену инклюда (самый надежный метод 2026)
    NIRI_CFG="$HOME/.config/niri/monitor.kdl"
    if [ "$CURRENT_HZ" -le "$LOW_HZ" ]; then
        NEW_HZ=$HIGH_HZ
        echo "output \"$MONITOR\" { mode \"1920x1080@$HIGH_HZ\"; }" > "$NIRI_CFG"
    else
        NEW_HZ=$LOW_HZ
        echo "output \"$MONITOR\" { mode \"1920x1080@60.004\"; }" > "$NIRI_CFG"
    fi

elif [ -n "$HYPRLAND_INSTANCE_SIGNATURE" ]; then
    # Логика для Hyprland через jq
    CURRENT_HZ=$(hyprctl monitors -j | jq -r ".[] | select(.name == \"$MONITOR\") | .refreshRate" | awk '{print int($1)}')

    if [ "$CURRENT_HZ" -le "$LOW_HZ" ]; then
        NEW_HZ=$HIGH_HZ
        hyprctl keyword monitor "$MONITOR, 1920x1080@$HIGH_HZ, 0x0, 1"
    else
        NEW_HZ=$LOW_HZ
        hyprctl keyword monitor "$MONITOR, 1920x1080@60, 0x0, 1"
    fi
else
    notify-send -u critical "Error" "Unknown DE"
    exit 1
fi

# Универсальное уведомление
notify-send -a "System" -i "display" "Display Settings" "Refresh rate set to ${NEW_HZ}Hz"
