#!/bin/bash

# --- НАСТРОЙКИ ---
BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m'

# Получаем абсолютный путь к папке скрипта (твои дотфайлы)
DOTFILES_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
CONFIG_DIR="$HOME/.config"
BACKUP_DIR="$HOME/.config_backup_$(date +%Y%m%d_%H%M%S)"

# Зависимости и папки
DEPENDENCIES=("hyprland" "alacritty" "waybar" "swaync" "rofi")
CONFIGS=("hypr" "alacritty" "waybar" "swaync" "rofi")

echo -e "${BLUE}>>> Начало установки. Источник: $DOTFILES_DIR${NC}"

# 1. Проверка пакетов
echo -e "${BLUE}>>> Проверка пакетов...${NC}"
for pkg in "${DEPENDENCIES[@]}"; do
    if pacman -Qs "$pkg" > /dev/null; then
        echo -e "${GREEN}[OK]${NC} $pkg"
    else
        echo -e "${YELLOW}[!]${NC} $pkg не найден"
    fi
done

# 2. Создание ссылок
echo -e "${BLUE}>>> Настройка конфигураций...${NC}"
mkdir -p "$CONFIG_DIR"

for folder in "${CONFIGS[@]}"; do
    TARGET="$CONFIG_DIR/$folder"
    SOURCE="$DOTFILES_DIR/config/$folder"

    if [ -d "$SOURCE" ]; then
        # Если цель уже существует
        if [ -e "$TARGET" ] || [ -L "$TARGET" ]; then
            # Если это реальная папка (не ссылка) — делаем бэкап
            if [ -d "$TARGET" ] && [ ! -L "$TARGET" ]; then
                mkdir -p "$BACKUP_DIR"
                echo -e "${YELLOW}>>> Бэкап существующей папки $folder в $BACKUP_DIR${NC}"
                mv "$TARGET" "$BACKUP_DIR/"
            else
                # Если это старая ссылка — удаляем её перед пересозданием
                rm -rf "$TARGET"
            fi
        fi

        # Создаем симлинк (используем полные пути для надежности)
        ln -snf "$SOURCE" "$TARGET"
        
        # Проверка на успех
        if [ -L "$TARGET" ]; then
            echo -e "${GREEN}>>> Ссылка создана: $folder -> $SOURCE${NC}"
        else
            echo -e "${RED}>>> Ошибка при создании ссылки для $folder${NC}"
        fi
    else
        echo -e "${RED}>>> Ошибка: Исходная папка $SOURCE не найдена!${NC}"
    fi
done

echo -e "${BLUE}>>> Установка завершена.${NC}"