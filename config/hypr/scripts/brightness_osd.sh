#!/bin/bash

EWW_BIN="eww"
EWW_CONF="$HOME/.config/eww"
LOCK_FILE="/tmp/bright_osd_last_press"

# 1. Получаем яркость (в процентах)
BRIGHT=$(brightnessctl -m | cut -d, -f4 | tr -d '%')

# 2. Обновляем значение
${EWW_BIN} -c "${EWW_CONF}" update brightness_percent="${BRIGHT}"

# 3. Открываем окно, если оно закрыто
if ! ${EWW_BIN} -c "${EWW_CONF}" active-windows | grep -q "osd_bright"; then
    ${EWW_BIN} -c "${EWW_CONF}" open osd_bright
fi

# 4. Таймер
NOW=$(date +%s%N)
echo "$NOW" > "$LOCK_FILE"

while true; do
    sleep 2
    LAST_ID=$(cat "$LOCK_FILE" 2>/dev/null)
    if [ "$NOW" != "$LAST_ID" ]; then exit 0; fi

    IS_HOVERED=$(${EWW_BIN} -c "${EWW_CONF}" get osd_hover | tr -d '[:space:]' | tr -d '"')

    if [ "$IS_HOVERED" = "false" ]; then
        ${EWW_BIN} -c "${EWW_CONF}" close osd_bright
        rm -f "$LOCK_FILE"
        exit 0
    fi
done