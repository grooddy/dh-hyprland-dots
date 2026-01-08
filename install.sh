#!/bin/bash

# --- НАСТРОЙКИ ---
BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m'

# Полный путь к репозиторию
DOTFILES_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
BACKUP_DIR="$HOME/.config_backup_$(date +%Y%m%d_%H%M%S)"

# Что проверяем и что линкуем
DEPENDENCIES=("hyprland" "alacritty" "waybar" "swaync" "rofi")
# Важно: папку wallpapers положи в корень репозитория рядом с папкой config
CONFIG_FOLDERS=("hypr" "alacritty" "waybar" "swaync" "rofi")

echo -e "${BLUE}>>> Начало установки. Источник: $DOTFILES_DIR${NC}"

# 1. Проверка пакетов
echo -e "${BLUE}>>> Проверка пакетов...${NC}"
for pkg in "${DEPENDENCIES[@]}"; do
    if pacman -Qs "$pkg" > /dev/null; then
        echo -e "${GREEN}[OK]${NC} $pkg"
    else
        echo -e "${YELLOW}[!]${NC} $pkg не найден${NC}"
    fi
done

# 2. Линковка конфигов (в ~/.config)
echo -e "${BLUE}>>> Настройка конфигураций в ~/.config...${NC}"
mkdir -p "$HOME/.config"

for folder in "${CONFIG_FOLDERS[@]}"; do
    TARGET="$HOME/.config/$folder"
    SOURCE="$DOTFILES_DIR/config/$folder"

    if [ -d "$SOURCE" ]; then
        if [ -e "$TARGET" ] || [ -L "$TARGET" ]; then
            if [ -d "$TARGET" ] && [ ! -L "$TARGET" ]; then
                mkdir -p "$BACKUP_DIR"
                echo -e "${YELLOW}>>> Бэкап существующей папки $folder...${NC}"
                mv "$TARGET" "$BACKUP_DIR/"
            else
                rm -rf "$TARGET"
            fi
        fi
        ln -snf "$SOURCE" "$TARGET"
        echo -e "${GREEN}>>> Ссылка создана: .config/$folder${NC}"
    else
        echo -e "${RED}>>> Ошибка: $SOURCE не найден!${NC}"
    fi
done

# 3. Линковка обоев (в ~/Pictures/Wallpapers)
echo -e "${BLUE}>>> Настройка обоев...${NC}"
WALL_SOURCE="$DOTFILES_DIR/wallpapers"
WALL_TARGET="$HOME/Pictures/Wallpapers"

if [ -d "$WALL_SOURCE" ]; then
    mkdir -p "$HOME/Pictures"
    if [ -e "$WALL_TARGET" ] || [ -L "$WALL_TARGET" ]; then
        if [ -d "$WALL_TARGET" ] && [ ! -L "$WALL_TARGET" ]; then
            echo -e "${YELLOW}>>> Бэкап существующих обоев...${NC}"
            mv "$WALL_TARGET" "$HOME/Pictures/Wallpapers_bak_$(date +%Y%m%d)"
        else
            rm -rf "$WALL_TARGET"
        fi
    fi
    ln -snf "$WALL_SOURCE" "$WALL_TARGET"
    echo -e "${GREEN}>>> Обои слинкованы: ~/Pictures/Wallpapers -> $WALL_SOURCE${NC}"
else
    echo -e "${YELLOW}>>> Пропуск: Папка wallpapers не найдена в репозитории.${NC}"
fi

echo -e "${BLUE}>>> Установка завершена успешно!${NC}"