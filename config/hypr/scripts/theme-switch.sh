#!/bin/bash

# 1. Умная защита от зависания LOCKFILE
LOCKFILE="/tmp/theme_switch.lock"
if [ -f "$LOCKFILE" ]; then
    LAST_TOUCH=$(stat -c %Y "$LOCKFILE")
    CURRENT_TIME=$(date +%s)
    if [ $((CURRENT_TIME - LAST_TOUCH)) -gt 15 ]; then
        rm -f "$LOCKFILE"
    else
        exit 0
    fi
fi
touch "$LOCKFILE"
trap "rm -f $LOCKFILE" EXIT SIGINT SIGTERM

# ОПРЕДЕЛЕНИЕ ТЕКУЩЕГО РЕЖИМА
# Если аргумент не передан, узнаем текущую тему через gsettings
if [ -z "$1" ]; then
    CURRENT_SCHEME=$(gsettings get org.gnome.desktop.interface color-scheme)
    if [[ "$CURRENT_SCHEME" == *"'prefer-dark'"* ]]; then
        MODE="light"
    else
        MODE="dark"
    fi
else
    MODE=$1
fi

WALLPAPER=$2

if [ -z "$WALLPAPER" ]; then
    [ -f "$HOME/.cache/wal/wal" ] && WALLPAPER=$(cat "$HOME/.cache/wal/wal")
fi

# 2. Переменные тем
if [ "$MODE" = "light" ]; then
    GTK_THEME="WhiteSur-Light"
    ALACRITTY_VAR="Light"
    ALACRITTY_OP="0.92"
    WAL_PARAM="-l"
else
    GTK_THEME="WhiteSur-Dark"
    ALACRITTY_VAR="Dark"
    ALACRITTY_OP="0.8"
    WAL_PARAM=""
fi

# 3. GTK и Alacritty (делаем сразу)
gsettings set org.gnome.desktop.interface color-scheme "prefer-$MODE" > /dev/null 2>&1
gsettings set org.gnome.desktop.interface gtk-theme "$GTK_THEME" > /dev/null 2>&1

if [ -f ~/.config/alacritty/alacritty.toml ]; then
    sed -i "s/decorations_theme_variant = .*/decorations_theme_variant = \"$ALACRITTY_VAR\"/" ~/.config/alacritty/alacritty.toml
    sed -i "s/opacity = .*/opacity = $ALACRITTY_OP/" ~/.config/alacritty/alacritty.toml
fi

# 4. Обои и Pywal (основная работа)
hyprctl hyprpaper preload "$WALLPAPER" > /dev/null 2>&1
hyprctl hyprpaper wallpaper "eDP-1,$WALLPAPER" > /dev/null 2>&1
# Пытаемся запустить wal. Если он падает (exit code не 0), запускаем с бэкендом colorz или haishoku
if ! wal -i "$WALLPAPER" $WAL_PARAM -n --backend wal --saturate 0.8; then
    echo "Wal failed, trying colorz..."
    wal -i "$WALLPAPER" $WAL_PARAM -n --backend fastwal --saturate 0.8
fi

# 5. Waybar (обновляем быстро)
pkill -SIGUSR2 waybar

# 6. УВЕДОМЛЕНИЕ (Отправляем ДО перезапуска SwayNC)
# Мы отправляем его сейчас, чтобы старый процесс SwayNC его показал перед смертью
notify-send -a "System" -i "$WALLPAPER" "Тема: ${MODE^}" "Интерфейс обновлен"
sleep 0.5 # Даем полсекунды уведомлению отрисоваться

# 7. ОБНОВЛЕНИЕ SWAYNC (Мягкое)
(
    swaync-client -rs > /dev/null 2>&1
    
    # Проверка через -f для надежности
    if ! pgrep -f "swaync" > /dev/null; then
        setsid swaync > /dev/null 2>&1 &
    fi
) &

# 8. Фоновые задачи
(python3 -m pywalfox update > /dev/null 2>&1) &
(sleep 3 && hyprctl hyprpaper unload unused > /dev/null 2>&1) &
# 9. ОБНОВЛЕНИЕ NWG-DOCK
(
    pkill -f nwg-dock-hyprland
    sleep 0.4
    
    # Заходим в папку, где лежит стиль
    cd "$HOME/.config/nwg-dock-hyprland" || exit
    
    # Запускаем, указывая только ИМЯ файла, а не путь
    uwsm app -- nwg-dock-hyprland -i 54 -mb 10 -a center -d -p bottom -x -s style.css &
) &
exit 0