#!/bin/bash

# --- НАСТРОЙКИ ---
BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m'

DOTFILES_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
CONFIG_DIR="$HOME/.config"
BACKUP_DIR="$HOME/.config_backup_$(date +%Y%m%d_%H%M%S)"

# Список софта для проверки (зависимости)
DEPENDENCIES=("hyprland" "alacritty" "waybar" "swaync" "rofi" "jetbrains-mono-nerd-font")
# Папки для линковки
CONFIGS=("hypr" "alacritty" "waybar" "swaync" "rofi")

echo -e "${BLUE}>>> Подготовка к установке дотфайлов...${NC}"

# 1. Проверка зависимостей (только инфо)
echo -e "${BLUE}>>> Проверка установленных пакетов...${NC}"
for pkg in "${DEPENDENCIES[@]}"; do
    if pacman -Qs "$pkg" > /dev/null; then
        echo -e "${GREEN}[OK]${NC} $pkg установлен."
    else
        echo -e "${YELLOW}[!]${NC} $pkg не найден. Установите его позже: sudo pacman -S $pkg"
    fi
done

# 2. Создание ссылок
echo -e "${BLUE}>>> Создание символических ссылок...${NC}"
mkdir -p "$CONFIG_DIR"

for folder in "${CONFIGS[@]}"; do
    TARGET="$CONFIG_DIR/$folder"
    SOURCE="$DOTFILES_DIR/config/$folder"

    if [ -d "$SOURCE" ]; then
        # Если там реальная папка (не ссылка), делаем бэкап
        if [ -d "$TARGET" ] && [ ! -L "$TARGET" ]; then
            mkdir -p "$BACKUP_DIR"
            echo -e "${YELLOW}>>> Бэкап существующего $folder в $BACKUP_DIR${NC}"
            mv "$TARGET" "$BACKUP_DIR/"
        fi

        # Создаем симлинк (-s: ссылка, -n: не следовать за существующей ссылкой, -f: перезаписать)
        ln -snf "$SOURCE" "$TARGET"
        echo -e "${GREEN}>>> Ссылка создана: $folder${NC}"
    else
        echo -e "${RED}>>> Ошибка: Исходная папка $SOURCE не найдена!${NC}"
    fi
done

# 3. Финальный отчет
if [ -d "$BACKUP_DIR" ]; then
    echo -e "${BLUE}>>> Установка завершена. Бэкапы сохранены в: $BACKUP_DIR${NC}"
else
    echo -e "${BLUE}>>> Установка завершена. Бэкапы не потребовались.${NC}"
fi

echo -e "${GREEN}>>> Наслаждайтесь macOS-style Hyprland!${NC}"