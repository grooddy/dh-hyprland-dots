#!/bin/bash

# Переключаем (например, Hybrid -> Integrated -> Hybrid)
# Если у тебя только два режима, можно сделать просто переключатель:
CURRENT=$(supergfxctl -g)

if [ "$CURRENT" = "Hybrid" ]; then
    supergfxctl -m Integrated
    notify-send -a "GPU Mode" -i "gpu" "GPU Switched" "Mode: Integrated (Eco)"
else
    supergfxctl -m Hybrid
    notify-send -a "GPU Mode" -i "gpu" "GPU Switched" "Mode: Hybrid (Performance)"
fi
supergfxctl -g > /tmp/gpu_status.txt
swaync-client -R && swaync-client -rs
VAL=$(supergfxctl -g)
swaync-client -pd "{\"label#gpu\": {\"text\": \"󰢮 GPU: $VAL\"}}"