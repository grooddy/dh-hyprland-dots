#!/bin/bash

# 1. Путь к кэшу последних обоев
WAL_CACHE="$HOME/.cache/wal/wal"

# Если кэша нет (первый запуск), вызываем рандомайзер и выходим
if [ ! -f "$WAL_CACHE" ]; then
    bash ~/.config/hypr/scripts/wallpaper-change.sh
    exit 0
fi

# 2. Считываем сохраненные данные
WALLPAPER=$(cat "$WAL_CACHE")
CURRENT_MODE=$(gsettings get org.gnome.desktop.interface color-scheme | tr -d "'")
[[ "$CURRENT_MODE" == *"light"* ]] && MODE="light" || MODE="dark"

# 3. Инициализируем hyprpaper, если он не запущен
if ! pgrep -x "hyprpaper" > /dev/null; then
    echo "preload = $WALLPAPER" > /tmp/hyprpaper.conf
    echo "wallpaper = eDP-1,$WALLPAPER" >> /tmp/hyprpaper.conf
    hyprpaper -c /tmp/hyprpaper.conf &
    sleep 0.5
fi

# 4. Применяем цвета Pywal (восстанавливаем из кэша)
wal -i "$WALLPAPER" ${MODE:+"${MODE/light/-l}"} -n -q --backend wal > /dev/null 2>&1

# 5. Обновляем интерфейсы
pkill -SIGUSR2 waybar
swaync-client -rs > /dev/null 2>&1

# 6. Уведомление о восстановлении сессии
notify-send -a "DH UI" "Сессия восстановлена" "Theme: ${MODE^}"