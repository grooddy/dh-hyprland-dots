#!/usr/bin/env bash

# Иконки (можешь заменить на свои)
ICON_PERF="󰓅"
ICON_BAL="󰾆"
ICON_QUIET="󰊠"

# 1. Логика переключения (для SwayNC и клика по Waybar)
if [[ "$1" == "--toggle" ]]; then
    # Переключаем профиль через asusctl (без sudo!)
    asusctl profile next > /dev/null

    # Получаем имя нового профиля для уведомления
    NEW=$(asusctl profile get | grep "Active profile" | awk '{print $3}')

    notify-send -a "Asus System" -t 1500 "Power Profile" "Switched to $NEW"

    # --- МАГИЯ ОБНОВЛЕНИЯ WAYBAR ---
    pkill -RTMIN+8 waybar
    exit 0
fi

# 2. Логика вывода JSON (для Waybar exec)
CURRENT=$(asusctl profile get | grep "Active profile" | awk '{print $3}')

# 3. Определяем текст и иконку
case "$CURRENT" in
    Performance)
        ICON="$ICON_PERF"
        TEXT="Макс. мощь"
        CLASS="perf"
        ;;
    Quiet)
        ICON="$ICON_QUIET"
        TEXT="Тихий"
        CLASS="quiet"
        ;;
    Balanced)
        ICON="$ICON_BAL"
        TEXT="Баланс"
        CLASS="balanced"
        ;;
    *)
        ICON="󰓅"
        TEXT="$CURRENT"
        CLASS="unknown"
        ;;
esac
echo "{\"text\": \"$ICON $TEXT\", \"tooltip\": \"Profile: $CURRENT\", \"class\": \"$CLASS\"}"
