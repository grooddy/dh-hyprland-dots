#!/bin/bash
# Путь: ~/.config/hypr/scripts/colors-update.sh

# 1. Определяем текущие обои и режим
# Если используешь swww, вытягиваем текущий файл. Если нет — берем из кеша.
WALLPAPER=$(swww query | awk -F 'image: ' '{print $2}')
[ -z "$WALLPAPER" ] && WALLPAPER=$(cat "$HOME/.cache/swww/default") # Фолбэк

CURRENT_MODE=$(gsettings get org.gnome.desktop.interface color-scheme | tr -d "'")
[[ "$CURRENT_MODE" == *"light"* ]] && MODE="light" || MODE="dark"

# 2. Запускаем Matugen
# -m устанавливает режим (dark/light)
# -c указывает путь к конфигу (если есть)
matugen image "$WALLPAPER" -m "$MODE" > /dev/null 2>&1

# 3. Даем долям секунды на запись файлов в ~/.cache/matugen/
sleep 0.2

# 4. Обновляем компоненты
# Waybar (отправляем сигнал для перезагрузки CSS)
pkill -SIGUSR2 waybar

# SwayNC (перезагружаем стили)
swaync-client -rs > /dev/null 2>&1

# Firefox (если используешь Pywalfox, он может конфликтовать с Matugen напрямую, 
# но если есть скрипт-прослойка, запускаем его здесь)
if command -v pywalfox &> /dev/null; then
    pywalfox update > /dev/null 2>&1
fi

# 5. Премиальное уведомление
WALL_NAME=$(basename "$WALLPAPER")
notify-send -a "System UI" \
            -i "$WALLPAPER" \
            -t 3000 \
            "Design Updated" \
            "Theme: ${MODE^}\nPalette: Material You (Matugen)\nWallpaper: $WALL_NAME"