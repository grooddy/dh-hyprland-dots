#!/bin/bash

# Переключаем профиль на следующий
asusctl profile -n > /dev/null

# Небольшая пауза, чтобы контроллер успел обновить статус
sleep 0.1

# Получаем название нового профиля
PROFILE=$(asusctl profile -p | grep 'Active profile' | awk '{print $NF}')

# Отправляем уведомление
notify-send -a "Asus System" -i "battery-full-symbolic" "Power Profile" "Active: $PROFILE"
asusctl profile -p | grep 'Active profile' | awk '{print $NF}' > /tmp/power_status.txt
swaync-client -R && swaync-client -rs
VAL=$(asusctl profile -p | grep 'Active profile' | awk '{print $NF}')
swaync-client -pd "{\"label#power\": {\"text\": \"󰈐 Power: $VAL\"}}"