#!/bin/bash

# 1. Жесткое закрытие всех потоков, чтобы SwayNC не мог ничего прочитать
exec 1>&-
exec 2>&-
exec 0<&-

# 2. Lockfile
LOCKFILE="/tmp/theme_switch.lock"
[ -f "$LOCKFILE" ] && exit 0
touch "$LOCKFILE"
trap "rm -f $LOCKFILE" EXIT SIGINT SIGTERM

# ОПРЕДЕЛЕНИЕ РЕЖИМА
if [ -z "$1" ]; then
    CURRENT_SCHEME=$(gsettings get org.gnome.desktop.interface color-scheme)
    [[ "$CURRENT_SCHEME" == *"'prefer-dark'"* ]] && MODE="light" || MODE="dark"
else
    MODE=$1
fi
WALLPAPER=$2
[ -z "$WALLPAPER" ] && [ -f "$HOME/.cache/wal/wal" ] && WALLPAPER=$(cat "$HOME/.cache/wal/wal")

# 3. Настройки тем
gsettings set org.gnome.desktop.interface color-scheme "prefer-$MODE"
gsettings set org.gnome.desktop.interface gtk-theme "WhiteSur-${MODE^}"

# 4. Обои и Pywal (Через миниатюру для скорости)
hyprctl hyprpaper preload "$WALLPAPER" > /dev/null 2>&1
hyprctl hyprpaper wallpaper "eDP-1,$WALLPAPER" > /dev/null 2>&1

magick "$WALLPAPER" -resize 100x100 /tmp/wal_sample.png
wal -i "/tmp/wal_sample.png" ${MODE:+"${MODE/light/-l}"} -n -q --backend wal --saturate 0.8 > /dev/null 2>&1

# 5. Обновление графики (ОЧЕНЬ осторожно)
(
    pkill -SIGUSR2 waybar
    
    # Ждем подольше, чтобы SwayNC успел закрыть меню после клика
    sleep 0.8 
    
    if pgrep -x "swaync" > /dev/null; then
        # Обновляем только CSS
        swaync-client -rs > /dev/null 2>&1
    else
        uwsm app -- swaync > /dev/null 2>&1 &
    fi
) &

# 6. Остальное
(
    pkill -f "nwg-dock-hyprland"
    sleep 1.0
    uwsm app -- nwg-dock-hyprland -i 54 -mb 10 -a center -d -p bottom -x -s "$HOME/.config/nwg-dock-hyprland/style.css" > /dev/null 2>&1 &
    
    python3 -m pywalfox update > /dev/null 2>&1
    notify-send -a "System" -i "$WALLPAPER" "Тема: ${MODE^}" "Интерфейс готов"
) &

exit 0