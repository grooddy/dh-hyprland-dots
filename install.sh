#!/bin/bash

# Цвета для красоты
BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m'

DOTFILES_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
CONFIG_DIR="$HOME/.config"
BACKUP_DIR="$HOME/.config_backup_$(date +%Y%m%d_%H%M%S)"

# Список папок для синхронизации
CONFIGS=("hypr" "alacritty" "waybar" "swaync" "rofi")

echo -e "${BLUE}>>> Запуск установки дотфайлов...${NC}"

# Создаем папку для бэкапа
mkdir -p "$BACKUP_DIR"

for folder in "${CONFIGS[@]}"; do
    TARGET="$CONFIG_DIR/$folder"
    SOURCE="$DOTFILES_DIR/config/$folder"

    if [ -d "$SOURCE" ]; then
        # Если конфиг уже существует и это не ссылка — делаем бэкап
        if [ -d "$TARGET" ] && [ ! -L "$TARGET" ]; then
            echo -e "${YELLOW}!!! Резервное копирование существующего $folder в $BACKUP_DIR${NC}"
            cp -r "$TARGET" "$BACKUP_DIR/"
            rm -rf "$TARGET"
        # Если это уже симлинк — просто удаляем его, чтобы пересоздать
        elif [ -L "$TARGET" ]; then
            rm "$TARGET"
        fi

        # Создаем симлинк
        ln -s "$SOURCE" "$TARGET"
        echo -e "${GREEN}+++ Ссылка создана: $folder${NC}"
    else
        echo -e "${YELLOW}--- Пропуск: папка $folder не найдена в дотфайлах${NC}"
    fi
done

echo -e "${BLUE}>>> Установка завершена! Бэкап старых конфигов (если были) тут: $BACKUP_DIR${NC}"