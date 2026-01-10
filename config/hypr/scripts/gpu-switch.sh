#!/bin/bash

LOCKFILE="/tmp/gpu_switch.lock"
[ -f "$LOCKFILE" ] && exit 0
touch "$LOCKFILE"
trap "rm -f $LOCKFILE" EXIT

CURRENT=$(supergfxctl -g)

if [ "$CURRENT" = "Hybrid" ]; then
    NEW_MODE="Integrated"
    ICON="power-profile-efficiency-symbolic"
    DESC="Mode: Integrated (Экономия)"
else
    NEW_MODE="Hybrid"
    ICON="power-profile-performance-symbolic"
    DESC="Mode: Hybrid (Производительность)"
fi

# Выполняем переключение
supergfxctl -m "$NEW_MODE" > /dev/null 2>&1

# Уведомление
notify-send -a "GPU Mode" -i "$ICON" "GPU Переключен" "$DESC"

# Обновляем только нужный текст в SwayNC, не трогая остальное
swaync-client -pd "{\"custom-gpu\": {\"text\": \"GPU: $NEW_MODE\"}}" > /dev/null 2>&1

# Сохраняем статус для Waybar
echo "$NEW_MODE" > /tmp/gpu_status.txt
pkill -SIGUSR2 waybar