#!/bin/bash
while true; do
    # Проверяем текущее время (с 7 утра до 19 вечера - светлая тема)
    HOUR=$(date +%H)
    if [ $HOUR -ge 07 ] && [ $HOUR -lt 19 ]; then
        ~/.config/hypr/scripts/theme-switch.sh light
    else
        ~/.config/hypr/scripts/theme-switch.sh dark
    fi
    sleep 900 # Менять каждые 15 минут
done