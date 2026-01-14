#!/bin/bash
# Путь: ~/.config/hypr/scripts/wallpaper-change.sh

WALL_DIR="$HOME/Pictures/Wallpapers"
CACHE_PATH="$HOME/.cache/swww_current"
# 1. Поиск обоев с проверкой
# Добавили проверку существования директории
if [ ! -d "$WALL_DIR" ]; then
    notify-send "Error" "Wallpaper directory not found: $WALL_DIR"
    exit 1
fi
# 1. Поиск случайных обоев (с поддержкой символических ссылок)
WALLPAPER=$(find -L "$WALL_DIR" -type f \( -name "*.jpg" -o -name "*.png" -o -name "*.jpeg" -o -name "*.webp" \) | shuf -n 1)
# Проверка: нашли ли мы файл?
if [ -z "$WALLPAPER" ]; then
    notify-send "Error" "No images found in $WALL_DIR"
    exit 1
fi
# 2. Проверка, запущен ли демон swww (вместо hyprpaper)
if ! pgrep -x "swww-daemon" > /dev/null; then
    swww-daemon --format argb & # Исправили xrgb на argb
    sleep 0.5
fi

# 3. Плавная смена обоев через swww
# Используем эффект 'outer' или 'grow' для эффекта "всплытия" из центра
swww img "$WALLPAPER" \
    --transition-type grow \
    --transition-pos 0.5,0.5 \
    --transition-step 90 \
    --transition-duration 1.2

# 4. Обновление темы Matugen
# Определяем текущий режим системы (dark/light)
CURRENT_MODE=$(gsettings get org.gnome.desktop.interface color-scheme | tr -d "'")
[[ "$CURRENT_MODE" == *"light"* ]] && MODE="light" || MODE="dark"

matugen image "$WALLPAPER" -m "$MODE"

# 5. Запуск скрипта обновления всех интерфейсов
# Теперь он подхватит новые цвета Matugen из кэша
bash ~/.config/hypr/scripts/colors-update.sh

# 6. Сохраняем путь для следующей загрузки системы
echo "$WALLPAPER" > "$CACHE_PATH"