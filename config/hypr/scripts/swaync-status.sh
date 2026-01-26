#!/usr/bin/env bash
GPU=$(cat /tmp/gpu_status.txt 2>/dev/null || supergfxctl -g)
POWER=$(cat /tmp/power_status.txt 2>/dev/null || asusctl profile -p | grep 'Active profile' | awk '{print $NF}')

# Отправляем статичное уведомление, которое заменяет предыдущее (через ID 999)
notify-send -r 999 -u low "Статус системы" "󰢮 $GPU  |  󰈐 $POWER"
