#!/bin/bash

# Находим путь к папке скриптов
SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

# ТЕПЕРЬ ПУТЬ ВЕДЕТ ВНУТРЬ ДОТФАЙЛОВ
# Мы берем папку Pictures/Wallpapers, так как мы её слинковали
WALL_DIR="$HOME/Pictures/Wallpapers"

# 1. Поиск случайной картинки
WALLPAPER=$(find -L "$WALL_DIR" -type f \( -name "*.jpg" -o -name "*.png" -o -name "*.jpeg" -o -name "*.webp" \) | shuf -n 1)

if [ -z "$WALLPAPER" ]; then
    echo "Обои не найдены в $WALL_DIR"
    exit 1
fi

# 2. Определяем режим
CURRENT_MODE=$(gsettings get org.gnome.desktop.interface color-scheme | tr -d "'")
MODE="dark"
[[ "$CURRENT_MODE" == *"light"* ]] && MODE="light"

# 3. Запускаем свитчер темы
# Используем полный путь к theme-switch.sh в той же папке
bash "$SCRIPT_DIR/theme-switch.sh" "$MODE" "$WALLPAPER"