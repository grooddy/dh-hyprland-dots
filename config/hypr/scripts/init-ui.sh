#!/bin/bash

# 1. Параметры
WALL_DIR="$HOME/Pictures/Wallpapers"
CACHE_WALL="$HOME/.cache/swww/default"

if [ -f "$CACHE_WALL" ]; then
    WALLPAPER=$(cat "$CACHE_WALL")
else
    WALLPAPER=$(find "$WALL_DIR" -type f | head -n 1)
fi

# 2. Инициализация swww
if ! pgrep -x "swww-daemon" > /dev/null; then
    swww-daemon --format xrgb &
    sleep 0.8 # Увеличим задержку для Niri
fi

# 3. Установка обоев
swww img "$WALLPAPER" \
    --transition-type grow \
    --transition-pos 0.5,0.5 \
    --transition-step 90 \
    --transition-duration 1.5

# 4. Генерация темы Matugen
CURRENT_MODE=$(gsettings get org.gnome.desktop.interface color-scheme | tr -d "'")
[[ "$CURRENT_MODE" == *"light"* ]] && MODE="light" || MODE="dark"

matugen image "$WALLPAPER" -m "$MODE"

# 5. Обновление компонентов (Waybar, SwayNC и т.д.)
bash "$HOME/.config/hypr/scripts/colors-update.sh"

# 6. Умная установка курсора
# Проверяем, в какой мы сессии, чтобы не сыпать ошибками в лог
if [ "$XDG_CURRENT_DESKTOP" = "Hyprland" ]; then
    hyprctl setcursor WhiteSur 24
elif [ "$XDG_CURRENT_DESKTOP" = "niri" ]; then
    # Niri берет курсор из системных настроек gsettings или напрямую из конфига
    gsettings set org.gnome.desktop.interface cursor-theme 'WhiteSur'
    gsettings set org.gnome.desktop.interface cursor-size 24
fi