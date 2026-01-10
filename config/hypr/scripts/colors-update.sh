#!/bin/bash
# Путь: ~/.config/hypr/scripts/colors-update.sh

# 1. Получаем текущие данные
WALLPAPER=$(cat "$HOME/.cache/wal/wal")
CURRENT_MODE=$(gsettings get org.gnome.desktop.interface color-scheme | tr -d "'")
[[ "$CURRENT_MODE" == *"light"* ]] && MODE="light" || MODE="dark"

# 2. Запускаем Pywal (без применения к терминалу)
wal -i "$WALLPAPER" ${MODE:+"${MODE/light/-l}"} -n -q --backend wal > /dev/null 2>&1
sleep 0.3

# 3. Обновляем софт
pkill -SIGUSR2 waybar
swaync-client -rs > /dev/null 2>&1

# Обновление Firefox (Pywalfox)
if command -v pywalfox &> /dev/null; then
    python3 -m pywalfox update > /dev/null 2>&1
fi

# 4. Уведомление
WALL_NAME=$(basename "$WALLPAPER")
notify-send  -a "DH UI" -i "$WALLPAPER" "DH UI" "Mode: ${MODE^}\nWallpaper: $WALL_NAME\nColors: Updated"