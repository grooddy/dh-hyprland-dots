#!/usr/bin/env bash

# Константы (иконки)
ICON_PERF="󰓅"
ICON_BAL="󰾆"
ICON_QUIET="󰊠"

# Функция получения данных от системы
get_active_profile() {
    # asusctl выдает строку "Active profile: Quiet", забираем последнее слово
    asusctl profile get | grep 'Active profile' | awk '{print $NF}'
}

# --- ЛОГИКА ПЕРЕКЛЮЧЕНИЯ (для SwayNC и клика по бару) ---
if [[ "$1" == "--toggle" ]]; then
    # Переключаем на следующий профиль (Quiet -> Balanced -> Performance)
    asusctl profile next > /dev/null

    # Получаем новое состояние
    CURRENT=$(get_active_profile)

    # Локализация для уведомлений
    case "$CURRENT" in
        Performance) MSG="Максимальная мощность" ;;
        Quiet)       MSG="Тихий режим" ;;
        Balanced)    MSG="Сбалансированный" ;;
        *)           MSG="$CURRENT" ;;
    esac

    # Отправляем уведомление
    notify-send -a "Asus System" -u low -t 1500 "Профиль питания" "Установлен: $MSG"

    # МАГИЯ: посылаем сигнал Waybar обновить именно этот модуль (SIGRTMIN+8)
    pkill -RTMIN+8 waybar
    exit 0
fi

# --- ЛОГИКА ВЫВОДА ДЛЯ WAYBAR (JSON) ---
CURRENT=$(get_active_profile)

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

# Выводим JSON, который Waybar распарсит автоматически
echo "{\"text\": \"$ICON $TEXT\", \"tooltip\": \"Системный профиль: $CURRENT\", \"class\": \"$CLASS\"}"
