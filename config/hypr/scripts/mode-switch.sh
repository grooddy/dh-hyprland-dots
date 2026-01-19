#!/bin/bash
# Путь: ~/.config/hypr/scripts/mode-switch.sh

CURRENT_SCHEME=$(gsettings get org.gnome.desktop.interface color-scheme | tr -d "'")

if [[ "$CURRENT_SCHEME" == *"prefer-dark"* ]]; then
    NEW_MODE="light"
    GS_MODE="prefer-light"
else
    NEW_MODE="dark"
    GS_MODE="prefer-dark"
fi

# Применяем системные настройки
gsettings set org.gnome.desktop.interface color-scheme "$GS_MODE"
# Если у тебя установлены темы WhiteSur-Dark и WhiteSur-Light
gsettings set org.gnome.desktop.interface gtk-theme "WhiteSur-${NEW_MODE^}"

# Вызываем оркестратор обновления
bash "$HOME/.config/hypr/scripts/colors-update.sh"