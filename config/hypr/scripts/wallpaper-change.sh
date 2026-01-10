#!/bin/bash
# Путь: ~/.config/hypr/scripts/wallpaper-change.sh

WALL_DIR="$HOME/Pictures/Wallpapers"
WALLPAPER=$(find -L "$WALL_DIR" -type f \( -name "*.jpg" -o -name "*.png" -o -name "*.jpeg" -o -name "*.webp" \) | shuf -n 1)

# Установка обоев в Hyprland
if ! pgrep -x "hyprpaper" > /dev/null; then
    hyprpaper &
    sleep 0.5
fi

hyprctl hyprpaper unload all > /dev/null 2>&1
hyprctl hyprpaper preload "$WALLPAPER" > /dev/null 2>&1
hyprctl hyprpaper wallpaper "eDP-1,$WALLPAPER" > /dev/null 2>&1

# Сохраняем путь для Pywal и вызываем обновление цветов
echo "$WALLPAPER" > "$HOME/.cache/wal/wal"
bash "$HOME/.config/hypr/scripts/colors-update.sh"