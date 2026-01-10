#!/bin/bash
# Путь: ~/.config/hypr/scripts/mode-switch.sh

CURRENT_SCHEME=$(gsettings get org.gnome.desktop.interface color-scheme | tr -d "'")

if [[ "$CURRENT_SCHEME" == *"prefer-dark"* ]]; then
    NEW_MODE="light"
else
    NEW_MODE="dark"
fi

# Применяем тему GTK
gsettings set org.gnome.desktop.interface color-scheme "prefer-$NEW_MODE"
gsettings set org.gnome.desktop.interface gtk-theme "WhiteSur-${NEW_MODE^}"

# Вызываем обновление цветов для Waybar/SwayNC
bash "$HOME/.config/hypr/scripts/colors-update.sh"