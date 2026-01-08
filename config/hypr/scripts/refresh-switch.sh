#!/bin/bash

# Имя монитора из твоего конфига
MONITOR="eDP-1"

# Получаем текущую герцовку из hyprctl
# Мы ищем строку с разрешением монитора и вытаскиваем число частоты
CURRENT_HZ=$(hyprctl monitors | grep -A 1 "$MONITOR" | grep "@" | awk -F'@' '{print $2}' | awk -F'.' '{print $1}')

if [ "$CURRENT_HZ" = "60" ]; then
    NEW_HZ="144"
    # Команда для Hyprland: монитор, разрешение@герцовка, позиция, масштаб
    hyprctl keyword monitor "$MONITOR, 1920x1080@144, 0x0, 1"
    notify-send -a "System" -i "display" "Display Settings" "Refresh rate set to 144Hz"
else
    NEW_HZ="60"
    hyprctl keyword monitor "$MONITOR, 1920x1080@60, 0x0, 1"
    notify-send -a "System" -i "display" "Display Settings" "Refresh rate set to 60Hz"
fi