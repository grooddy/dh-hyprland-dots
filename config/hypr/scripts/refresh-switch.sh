#!/usr/bin/env bash

# --- КОНФИГУРАЦИЯ ---
CONFIG_PATH="$HOME/.config/niri/config.kdl"
MONITOR="eDP-1"
LOW_HZ="60.004"
HIGH_HZ="144.000"
THRESHOLD=100

# --- 1. ОПРЕДЕЛЯЕМ КОМПОЗИТОР И ТЕКУЩУЮ ГЕРЦОВКУ ---
if pgrep -x "hyprland" > /dev/null; then
    COMPOSITOR="hyprland"
    CURRENT_HZ=$(hyprctl monitors -j | jq -r ".[] | select(.name == \"$MONITOR\") | .refreshRate" | awk '{print int($1)}')
elif pgrep -x "niri" > /dev/null; then
    COMPOSITOR="niri"
    # Для niri в NixOS сокет обычно подхватывается автоматически, но оставим запасной путь
    [ -z "$NIRI_ID" ] && export NIRI_ID=$(ls /run/user/$(id -u)/niri-*.sock 2>/dev/null | head -n 1)

    RAW_JSON=$(niri msg --json outputs 2>/dev/null)
    # Парсим индекс текущего режима и достаем частоту
    CURRENT_HZ=$(echo "$RAW_JSON" | jq -r "
        .[\"$MONITOR\"] as \$m |
        \$m.modes[\$m.current_mode].refresh_rate
    " | awk '{
        hz = $1;
        if (hz == "null" || hz == 0) { print 0; exit; }
        while (hz > 1000) { hz /= 1000; }
        print int(hz);
    }')
fi

# Проверка детекции
if [[ -z "$CURRENT_HZ" || "$CURRENT_HZ" -eq 0 ]]; then
    notify-send -u critical "Display Error" "Could not detect rate"
    exit 1
fi

# --- 2. ОПРЕДЕЛЯЕМ НОВЫЙ РЕЖИМ ---
if [ "$CURRENT_HZ" -gt "$THRESHOLD" ]; then
    NEW_HZ_VAL=$LOW_HZ
    MSG="Power Save Mode: 60Hz"
    ICON="battery-low"
    HYPR_CMD="keyword monitor $MONITOR, 1920x1080@60, 0x0, 1; keyword animations:enabled false"
else
    NEW_HZ_VAL=$HIGH_HZ
    MSG="Performance Mode: 144Hz"
    ICON="preferences-desktop-display"
    HYPR_CMD="keyword monitor $MONITOR, 1920x1080@144, 0x0, 1; keyword animations:enabled true"
fi

# --- 3. ПРИМЕНЯЕМ НАСТРОЙКИ ---
if [ "$COMPOSITOR" == "hyprland" ]; then
    hyprctl --batch "$HYPR_CMD"

elif [ "$COMPOSITOR" == "niri" ]; then
    # Senior Way: Редактируем конфиг через sed.
    # Ищем строку mode "1920x1080@любое_число" и меняем на новое.
    if [ -f "$CONFIG_PATH" ]; then
        sed -i "s/mode \"1920x1080@[^\"]*\"/mode \"1920x1080@$NEW_HZ_VAL\"/" "$CONFIG_PATH"
        # Перечитываем конфиг (эта команда у тебя точно есть в списке help)
        niri msg action load-config-file
    else
        notify-send -u critical "Error" "Config file not found at $CONFIG_PATH"
        exit 1
    fi
fi

# --- 4. УВЕДОМЛЕНИЕ ---
notify-send -a "System" -r 9912 -i "$ICON" "Display Settings" "$MSG"
