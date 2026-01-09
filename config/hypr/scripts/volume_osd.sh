#!/bin/bash

EWW_BIN="eww"
EWW_CONF="$HOME/.config/eww"
LOCK_FILE="/tmp/vol_osd_last_press"

# 1. Получаем громкость
VOL=$(pamixer --get-volume | tr -d '%')
[ -z "$VOL" ] && VOL=0

# 2. Обновляем значение (используем кавычки для путей)
${EWW_BIN} -c "${EWW_CONF}" update volume_percent="${VOL}"

# 3. Открываем окно, если оно не открыто
if ! ${EWW_BIN} -c "${EWW_CONF}" active-windows | grep -q "osd_vol"; then
    ${EWW_BIN} -c "${EWW_CONF}" open osd_vol
fi

# 4. Логика таймера
NOW=$(date +%s%N)
echo "$NOW" > "$LOCK_FILE"

while true; do
    sleep 2
    
    # Проверяем, не нажал ли пользователь кнопку снова
    LAST_ID=$(cat "$LOCK_FILE" 2>/dev/null)
    if [ "$NOW" != "$LAST_ID" ]; then
        exit 0
    fi

    # Считываем статус ховера и очищаем от лишних символов
    IS_HOVERED=$(${EWW_BIN} -c "${EWW_CONF}" get osd_hover | tr -d '[:space:]' | tr -d '"')

    # Если мышь не наведена — закрываем и выходим
    if [ "$IS_HOVERED" = "false" ]; then
        ${EWW_BIN} -c "${EWW_CONF}" close osd_vol
        rm -f "$LOCK_FILE"
        exit 0
    fi
    # Если true — цикл идет на следующий круг sleep
done