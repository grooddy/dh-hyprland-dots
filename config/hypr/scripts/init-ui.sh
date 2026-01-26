#!/usr/bin/env bash
# Путь: ~/.config/hypr/scripts/init-ui.sh

LOG_FILE="/tmp/init-ui.log"
exec > "$LOG_FILE" 2>&1

log() { echo -e "[$(date +'%H:%M:%S')] $1"; }

log "--- UI Startup Sequence Initiated ---"

# 1. Ждем, пока Wayland реально станет доступен (важно для автостарта)
MAX_RETRIES=50
COUNT=0
while [ -z "$WAYLAND_DISPLAY" ] && [ $COUNT -lt $MAX_RETRIES ]; do
    sleep 0.1
    ((COUNT++))
done

if [ -z "$WAYLAND_DISPLAY" ]; then
    log "ERROR: WAYLAND_DISPLAY not found after waiting. Exiting."
    exit 1
fi

log "Wayland display found: $WAYLAND_DISPLAY"

# 2. Параметры и окружение
CACHE_PATH="$HOME/.cache/swww_current"
WALL_DIR="$HOME/Pictures/Wallpapers"
UWSM_BIN=$(command -v uwsm)

run_app() {
    local cmd=$1
    local proc_name=$1

    # Сопоставляем команду с реальным именем процесса
    [[ "$cmd" == "swaync" ]] && proc_name="swaync"

    # Используем -f, чтобы избежать ошибки "длиннее 15 символов"
    if ! pgrep -f "$proc_name" > /dev/null; then
        log "Attempting to start $cmd..."
        # Если юнит маскирован, uwsm может не сработать.
        # Попробуем запустить как обычное приложение через uwsm app
        uwsm app -- "$cmd" &
        sleep 1
    else
        log "SKIP: $proc_name is already running."
    fi
}

# 4. Обои и Matugen (делаем ПЕРЕД Waybar, чтобы он сразу увидел стили)
if [ -f "$CACHE_PATH" ] && [ -f "$(cat "$CACHE_PATH")" ]; then
    WALLPAPER=$(cat "$CACHE_PATH")
else
    WALLPAPER=$(find -L "$WALL_DIR" -type f \( -name "*.jpg" -o -name "*.png" \) | shuf -n 1)
    echo "$WALLPAPER" > "$CACHE_PATH"
fi

# Поднимаем swww-daemon
if ! pgrep -x "swww-daemon" > /dev/null; then
    swww-daemon --format argb &
    for i in {1..30}; do swww query &>/dev/null && break || sleep 0.1; done
fi
swww img "$WALLPAPER" --transition-type none &

# Генерация темы
CURRENT_MODE=$(gsettings get org.gnome.desktop.interface color-scheme | tr -d "'")
[[ "$CURRENT_MODE" == *"light"* ]] && MODE="light" || MODE="dark"

log "Applying Matugen..."
matugen image "$WALLPAPER" -m "$MODE" > /dev/null 2>&1
sed -i '/transform:/d' "$HOME/.cache/matugen/colors.css" 2>/dev/null

# 5. ЗАПУСК UI (Главный момент)
# Сначала даем системе "продышаться"
sleep 0.5
run_app waybar
run_app swaync

# 6. Финальное обновление сигналов
bash "$HOME/.config/hypr/scripts/colors-update.sh" "$WALLPAPER"

log "--- UI Startup Sequence Finished ---"
