#!/bin/bash
# Путь: ~/.config/hypr/scripts/colors-update.sh

# Получаем обои (из аргумента или кеша)
WALLPAPER="${1:-$(cat "$HOME/.cache/swww_current")}"

# Определяем режим
CURRENT_MODE=$(gsettings get org.gnome.desktop.interface color-scheme | tr -d "'")
[[ "$CURRENT_MODE" == *"light"* ]] && MODE="light" || MODE="dark"

# 1. ГЕНЕРИРУЕМ ЦВЕТА (Matugen)
# Это критически важный шаг, который ты пропускал
if command -v matugen &> /dev/null; then
    matugen image "$WALLPAPER" -m "$MODE" > /dev/null 2>&1
    # Чистим артефакты (опционально)
    sed -i '/transform:/d' "$HOME/.cache/matugen/colors.css" 2>/dev/null
fi

# 2. ОБНОВЛЯЕМ КОМПОНЕНТЫ
# Waybar
pkill -SIGUSR2 waybar

# SwayNC
swaync-client -rs > /dev/null 2>&1

# Firefox (в фоне с таймаутом)
if command -v pywalfox &> /dev/null; then
    timeout 2s pywalfox update > /dev/null 2>&1 &
fi

# 3. УВЕДОМЛЕНИЕ
WALL_NAME=$(basename "$WALLPAPER")
notify-send -a "System UI" \
            -i "$WALLPAPER" \
            -t 3000 \
            "Theme Switched" \
            "Mode: ${MODE^}\nPalette: Material You\nWallpaper: $WALL_NAME"