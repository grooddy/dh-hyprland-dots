#!/bin/bash
# Путь: ~/.config/hypr/scripts/init-ui.sh

# 1. Параметры
WALL_DIR="$HOME/Pictures/Wallpapers"
# Берем последние использованные обои или случайные, если кэш пуст
[ -f "$HOME/.cache/swww/default" ] && WALLPAPER=$(cat "$HOME/.cache/swww/default") || WALLPAPER=$(find "$WALL_DIR" -type f | shuf -n 1)

# 2. Инициализация swww (демон для обоев)
if ! pgrep -x "swww-daemon" > /dev/null; then
    swww-daemon --format xrgb &
    sleep 0.5
fi

# 3. Установка обоев с премиальным переходом (эффект "раскрытия" из центра)
swww img "$WALLPAPER" \
    --transition-type grow \
    --transition-pos 0.5,0.5 \
    --transition-step 90 \
    --transition-duration 1.5

# 4. Генерация темы Matugen
# Автоматически определяем темную/светлую тему из системы
CURRENT_MODE=$(gsettings get org.gnome.desktop.interface color-scheme | tr -d "'")
[[ "$CURRENT_MODE" == *"light"* ]] && MODE="light" || MODE="dark"

echo "Applying Matugen with $MODE mode..."
matugen image "$WALLPAPER" -m "$MODE"

# 5. Синхронизация остальных компонентов
# Вызываем colors-update.sh для обновления Waybar, SwayNC и т.д.
bash "$HOME/.config/hypr/scripts/colors-update.sh"

# 6. Опционально: Обновление курсора (чтобы не баговал при старте)
hyprctl setcursor WhiteSur 24