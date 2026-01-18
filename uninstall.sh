#!/bin/bash

RED='\033[0;31m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
GREEN='\033[0;32m'
NC='\033[0m'

CONFIG_DIR="$HOME/.config"
# Стандартные папки
CONFIGS=("hypr" "alacritty" "waybar" "swaync" "rofi" "eww" "matugen" "wlogout" "networkmanager-dmenu")
WALL_TARGET="$HOME/Pictures/Wallpapers"

echo -e "${RED}>>> Начало отмены установки симлинков...${NC}"

# 1. Удаление ссылок на стандартные конфиги
for folder in "${CONFIGS[@]}"; do
    TARGET="$CONFIG_DIR/$folder"
    
    if [ -L "$TARGET" ]; then
        rm "$TARGET"
        echo -e "${RED}--- Удалена ссылка: .config/$folder${NC}"
    elif [ -d "$TARGET" ] && [ ! -L "$TARGET" ]; then
        echo -e "${YELLOW}--- Пропуск: .config/$folder (реальная папка)${NC}"
    fi
done

# 2. Удаление ссылок VS Code (Code - OSS)
# Здесь мы удаляем ссылки только на файлы, не трогая саму папку User
echo -e "${RED}>>> Очистка ссылок VS Code (Code - OSS)...${NC}"
VS_TARGET_DIR="$HOME/.config/Code - OSS/User"
VS_FILES=("settings.json" "keybindings.json")

if [ -d "$VS_TARGET_DIR" ]; then
    for file in "${VS_FILES[@]}"; do
        FILE_PATH="$VS_TARGET_DIR/$file"
        if [ -L "$FILE_PATH" ]; then
            rm "$FILE_PATH"
            echo -e "${RED}--- Удалена ссылка VS Code: $file${NC}"
        fi
    done
fi

# 3. Удаление шаблонов Matugen
echo -e "${RED}>>> Очистка шаблонов Matugen...${NC}"
MATUGEN_TEMPLATES="$HOME/.config/matugen/templates"
if [ -d "$MATUGEN_TEMPLATES" ]; then
    # Удаляем только ссылки внутри папки шаблонов
    find "$MATUGEN_TEMPLATES" -maxdepth 1 -type l -delete
    echo -e "${RED}--- Ссылки на шаблоны Matugen удалены.${NC}"
fi

# 4. Удаление ссылки на обои
if [ -L "$WALL_TARGET" ]; then
    rm "$WALL_TARGET"
    echo -e "${RED}--- Удалена ссылка на обои: $WALL_TARGET${NC}"
fi

# 5. Поиск и восстановление последнего бэкапа
LATEST_BACKUP=$(ls -d $HOME/.config_backup_* 2>/dev/null | sort -r | head -n 1)

if [ -n "$LATEST_BACKUP" ]; then
    echo -e "\n${BLUE}>>> Найден бэкап: $LATEST_BACKUP${NC}"
    read -p "Восстановить файлы из этого бэкапа? (y/n): " confirm
    if [[ $confirm == [yY] || $confirm == [дД] ]]; then
        # Копируем содержимое бэкапа обратно в .config
        # cp -af скопирует и папки, и файлы VS Code на свои места
        cp -af "$LATEST_BACKUP"/. "$CONFIG_DIR/"
        echo -e "${GREEN}>>> Файлы восстановлены из бэкапа.${NC}"
        
        read -p "Удалить папку бэкапа теперь? (y/n): " rm_backup
        if [[ $rm_backup == [yY] ]]; then
            rm -rf "$LATEST_BACKUP"
            echo -e "${RED}>>> Папка бэкапа удалена.${NC}"
        fi
    fi
fi

echo -e "\n${GREEN}>>> Готово. Система очищена от симлинков.${NC}"