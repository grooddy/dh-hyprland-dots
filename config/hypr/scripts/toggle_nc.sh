#!/bin/bash

LOCK="/tmp/swaync_toggle.lock"
# Время ожидания между кликами (в секундах)
COOLDOWN=0.4

# 1. Защита от "зависшего" файла блокировки
if [ -f "$LOCK" ]; then
    LAST_TOUCH=$(stat -c %Y "$LOCK")
    CURRENT_TIME=$(date +%s)
    # Если файлу больше 2 секунд, значит скрипт когда-то упал, удаляем
    if [ $((CURRENT_TIME - LAST_TOUCH)) -gt 2 ]; then
        rm -f "$LOCK"
    else
        exit 0
    fi
fi

# 2. Создаем блокировку
touch "$LOCK"

# 3. Выполняем переключение
# Убираем -sw, чтобы клиент корректно отработал запрос
swaync-client -t

# 4. Пауза и очистка
sleep $COOLDOWN
rm -f "$LOCK"