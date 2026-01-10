#!/bin/bash

# --- НАСТРОЙКИ ---
BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m'

DOTFILES_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
BACKUP_DIR="$HOME/.config_backup_$(date +%Y%m%d_%H%M%S)"

# Добавил eww в список зависимостей для проверки
DEPENDENCIES=("hyprland" "alacritty" "waybar" "swaync" "rofi" "eww" "pamixer" "brightnessctl")
CONFIG_FOLDERS=("hypr" "alacritty" "waybar" "swaync" "rofi" "eww")

echo -e "${BLUE}>>> Начало установки. Источник: $DOTFILES_DIR${NC}"

# 1. Проверка пакетов
echo -e "${BLUE}>>> Проверка пакетов...${NC}"
for pkg in "${DEPENDENCIES[@]}"; do
    if pacman -Qs "$pkg" > /dev/null; then
        echo -e "${GREEN}[OK]${NC} $pkg"
    else
        echo -e "${YELLOW}[!]${NC} Пакет $pkg не установлен. Некоторые функции могут не работать.${NC}"
    fi
done

# 2. Линковка конфигов
echo -e "${BLUE}>>> Настройка конфигураций в ~/.config...${NC}"
mkdir -p "$HOME/.config"

for folder in "${CONFIG_FOLDERS[@]}"; do
    TARGET="$HOME/.config/$folder"
    SOURCE="$DOTFILES_DIR/config/$folder"

    if [ -d "$SOURCE" ]; then
        if [ -e "$TARGET" ] || [ -L "$TARGET" ]; then
            # Если это реальная папка, а не ссылка — делаем бэкап
            if [ -d "$TARGET" ] && [ ! -L "$TARGET" ]; then
                mkdir -p "$BACKUP_DIR"
                echo -e "${YELLOW}>>> Бэкап существующей папки $folder...${NC}"
                mv "$TARGET" "$BACKUP_DIR/"
            else
                # Если это старая ссылка — просто удаляем её
                rm -rf "$TARGET"
            fi
        fi
        ln -snf "$SOURCE" "$TARGET"
        echo -e "${GREEN}>>> Ссылка создана: .config/$folder${NC}"
    else
        echo -e "${RED}>>> Ошибка: Исходная папка $SOURCE не найдена!${NC}"
    fi
done

# 3. Установка прав на скрипты (ВАЖНО для Eww и Hyprland)
echo -e "${BLUE}>>> Установка прав на исполнение для скриптов...${NC}"
if [ -d "$HOME/.config/hypr/scripts" ]; then
    chmod +x "$HOME/.config/hypr/scripts/"*.sh
    echo -e "${GREEN}>>> Скрипты в hypr/scripts теперь исполняемые.${NC}"
fi

# 4. Линковка обоев
echo -e "${BLUE}>>> Настройка обоев...${NC}"
WALL_SOURCE="$DOTFILES_DIR/wallpapers"
WALL_TARGET="$HOME/Pictures/Wallpapers"

if [ -d "$WALL_SOURCE" ]; then
    mkdir -p "$HOME/Pictures"
    if [ -e "$WALL_TARGET" ] || [ -L "$WALL_TARGET" ]; then
        if [ -d "$WALL_TARGET" ] && [ ! -L "$WALL_TARGET" ]; then
            mv "$WALL_TARGET" "$HOME/Pictures/Wallpapers_bak_$(date +%Y%m%d)"
        else
            rm -rf "$WALL_TARGET"
        fi
    fi
    ln -snf "$WALL_SOURCE" "$WALL_TARGET"
    echo -e "${GREEN}>>> Обои слинкованы.${NC}"
fi

echo -e "${BLUE}>>> Установка завершена! Перезапустите Hyprland (Super+Shift+R).${NC}"