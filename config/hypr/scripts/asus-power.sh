#!/usr/bin/env bash

# Пути к системным файлам ASUS
PLATFORM_PROFILE="/sys/user_names/platform_profile" # Для новых ядер
# Или более старый вариант:
ASUS_PROFILE="/sys/devices/platform/asus-nb-wmi/throttle_thermal_policy"

# Иконки для Waybar
ICON_PERF="󰓅" # Performance
ICON_BAL="󰾆"  # Balanced
ICON_QUIET="󰊠" # Quiet

get_profile() {
    if [ -f "/sys/firmware/acpi/platform_profile" ]; then
        cat /sys/firmware/acpi/platform_profile
    elif [ -f "$ASUS_PROFILE" ]; then
        case $(cat "$ASUS_PROFILE") in
            0) echo "balanced" ;;
            1) echo "performance" ;;
            2) echo "quiet" ;;
        esac
    else
        echo "unknown"
    fi
}

set_profile() {
    CURRENT=$(get_profile)
    # Циклическое переключение
    case "$CURRENT" in
        balanced)    NEXT="performance" ;;
        performance) NEXT="quiet" ;;
        quiet)       NEXT="balanced" ;;
        *)           NEXT="balanced" ;;
    esac

    # Пробуем через platform_profile (нужен sudo или правила udev)
    if [ -f "/sys/firmware/acpi/platform_profile" ]; then
        echo "$NEXT" | sudo tee /sys/firmware/acpi/platform_profile
    fi

    # Отправляем уведомление
    notify-send "Power Profile" "Switched to $NEXT" -i "power-profile"
}

# Если запущен с аргументом --toggle
if [[ "$1" == "--toggle" ]]; then
    set_profile
    exit 0
fi

# Основной вывод для Waybar
PROFILE=$(get_profile)
case "$PROFILE" in
    performance) echo "{\"text\": \"$ICON_PERF\", \"tooltip\": \"Profile: Performance\", \"class\": \"perf\"}" ;;
    quiet)       echo "{\"text\": \"$ICON_QUIET\", \"tooltip\": \"Profile: Quiet\", \"class\": \"quiet\"}" ;;
    *)           echo "{\"text\": \"$ICON_BAL\", \"tooltip\": \"Profile: Balanced\", \"class\": \"balanced\"}" ;;
esac
