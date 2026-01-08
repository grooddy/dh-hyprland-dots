#!/bin/bash
# Директория с обоями
SCRIPT_DIR="$HOME/.config/hypr/scripts"
WALL_DIR="$HOME/Pictures/Wallpapers"

# 1. Поиск случайной картинки во всех подпапках
WALLPAPER=$(find -L "$WALL_DIR" -type f \( -name "*.jpg" -o -name "*.png" -o -name "*.jpeg" -o -name "*.webp" \) | shuf -n 1)

# 2. Определяем текущий режим (светлый или темный) из gsettings
# Чтобы новые обои применялись в текущем стиле
CURRENT_MODE=$(gsettings get org.gnome.desktop.interface color-scheme | tr -d "'")
if [[ "$CURRENT_MODE" == *"light"* ]]; then
    MODE="light"
else
    MODE="dark"
fi

# 3. Запускаем основной скрипт темы с найденными обоями
# (Предположим, основной скрипт называется theme_switch.sh)
bash "$SCRIPT_DIR/theme-switch.sh" "$MODE" "$WALLPAPER"