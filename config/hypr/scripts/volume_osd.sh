#!/bin/bash

EWW_BIN="eww"
EWW_CONF="$HOME/.config/eww"
OSD_NAME="osd_vol"

# 1. Если скрипт уже запущен — убиваем старую копию, чтобы сбросить таймер
# Это эффективнее, чем проверка LOCK_FILE внутри цикла
PID_FILE="/tmp/vol_osd.pid"
if [ -f "$PID_FILE" ]; then
    OLD_PID=$(cat "$PID_FILE")
    kill "$OLD_PID" 2>/dev/null
fi
echo "$$" > "$PID_FILE"

# 2. Получаем громкость
VOL=$(pamixer --get-volume)
[ -z "$VOL" ] && VOL=0

# 3. Обновляем значение и открываем окно
${EWW_BIN} -c "${EWW_CONF}" update volume_percent="${VOL}"

if ! ${EWW_BIN} -c "${EWW_CONF}" active-windows | grep -q "${OSD_NAME}"; then
    ${EWW_BIN} -c "${EWW_CONF}" open "${OSD_NAME}"
fi

# 4. Логика ожидания
sleep 2

# Бесконечный цикл проверки ховера (чтобы окно не закрылось, пока мышь на нем)
while true; do
    # Получаем значение и принудительно очищаем от кавычек и пробелов
    IS_HOVERED=$(${EWW_BIN} -c "${EWW_CONF}" get osd_hover | sed 's/"//g' | xargs)

    if [ "$IS_HOVERED" = "false" ] || [ -z "$IS_HOVERED" ]; then
        ${EWW_BIN} -c "${EWW_CONF}" close "${OSD_NAME}"
        rm -f "$PID_FILE"
        exit 0
    fi
    
    sleep 0.5 # Проверяем чаще, пока мышь наведена, чтобы мгновенно закрыть потом
done