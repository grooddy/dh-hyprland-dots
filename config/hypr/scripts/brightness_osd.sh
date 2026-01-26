#!/usr/bin/env bash

EWW_BIN="eww"
EWW_CONF="$HOME/.config/eww"
OSD_NAME="osd_bright"

# 1. Убиваем старый процесс этого же скрипта, если он запущен
# Это мгновенно сбрасывает таймер при повторном нажатии клавиши
PID_FILE="/tmp/bright_osd.pid"
if [ -f "$PID_FILE" ]; then
    OLD_PID=$(cat "$PID_FILE")
    kill "$OLD_PID" 2>/dev/null
fi
echo "$$" > "$PID_FILE"

# 2. Получаем яркость (более быстрый способ через -m)
BRIGHT=$(brightnessctl -m | cut -d, -f4 | tr -d '%')

# 3. Обновляем значение в Eww
${EWW_BIN} -c "${EWW_CONF}" update brightness_percent="${BRIGHT}"

# 4. Открываем окно, если оно еще не открыто
if ! ${EWW_BIN} -c "${EWW_CONF}" active-windows | grep -q "${OSD_NAME}"; then
    ${EWW_BIN} -c "${EWW_CONF}" open "${OSD_NAME}"
fi

# 5. Основная пауза перед закрытием (2 секунды)
sleep 2

# 6. Цикл проверки наведения мыши
while true; do
    # Используем sed для гарантированной очистки кавычек
    IS_HOVERED=$(${EWW_BIN} -c "${EWW_CONF}" get osd_hover | sed 's/"//g' | xargs)

    if [ "$IS_HOVERED" = "false" ] || [ -z "$IS_HOVERED" ]; then
        ${EWW_BIN} -c "${EWW_CONF}" close "${OSD_NAME}"
        rm -f "$PID_FILE"
        exit 0
    fi

    # Если мышь наведена, проверяем снова каждые полсекунды
    sleep 0.5
done
