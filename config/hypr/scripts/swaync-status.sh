#!/bin/bash

CONFIG="$HOME/.config/swaync/config.json"

while true; do
    GPU=$(supergfxctl -g)
    POWER=$(asusctl profile -p | grep 'Active profile' | awk '{print $NF}')
    
    # Меняем текст только в блоке label#gpu
    sed -i "/\"label#gpu\"/!b;n;c\      \"text\": \"󰢮 GPU: $GPU\"," "$CONFIG"
    
    # Меняем текст только в блоке label#power
    sed -i "/\"label#power\"/!b;n;c\      \"text\": \"󰈐 Power: $POWER\"," "$CONFIG"
    
    # Перезагружаем конфиг
    swaync-client -R
    
    sleep 5
done