#!/bin/bash
# Направляем ошибки в лог для отладки
exec > /tmp/init-ui.log 2>&1

CACHE_PATH="$HOME/.cache/swww_current"
WALL_DIR="$HOME/Pictures/Wallpapers"

# 1. Проверка обоев
if [ -f "$CACHE_PATH" ] && [ -f "$(cat "$CACHE_PATH")" ]; then
    WALLPAPER=$(cat "$CACHE_PATH")
else
    WALLPAPER=$(find -L "$WALL_DIR" -type f \( -name "*.jpg" -o -name "*.png" \) | shuf -n 1)
    echo "$WALLPAPER" > "$CACHE_PATH"
fi

# 2. Запуск swww через uwsm (если мы в сессии uwsm)
if ! pgrep -x "swww-daemon" > /dev/null; then
    uwsm app -- swww-daemon --format argb &
    # Ждем до 5 секунд появления сокета
    for i in {1..50}; do
        if swww query &>/dev/null; then break; fi
        sleep 0.1
    done
fi

# 3. Установка обоев
swww img "$WALLPAPER" --transition-type none

# 4. Matugen и темы
CURRENT_MODE=$(gsettings get org.gnome.desktop.interface color-scheme | tr -d "'")
[[ "$CURRENT_MODE" == *"light"* ]] && MODE="light" || MODE="dark"

matugen image "$WALLPAPER" -m "$MODE"
sed -i '/transform:/d' "$HOME/.cache/matugen/colors.css" 2>/dev/null

# 5. Обновление цветов
bash ~/.config/hypr/scripts/colors-update.sh

# Принудительный перезапуск swaync, если он не встал
if ! pgrep -x "swaync" > /dev/null; then
    uwsm app -- swaync &
fi