#!/bin/bash

RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

CONFIG_DIR="$HOME/.config"
CONFIGS=("hypr" "alacritty" "waybar" "swaync" "rofi")

echo -e "${RED}>>> Удаление симлинков дотфайлов...${NC}"

for folder in "${CONFIGS[@]}"; do
    TARGET="$CONFIG_DIR/$folder"
    
    if [ -L "$TARGET" ]; then
        rm "$TARGET"
        echo -e "${RED}--- Удалена ссылка: $folder${NC}"
    fi
done

# Поиск последнего бэкапа
LATEST_BACKUP=$(ls -d $HOME/.config_backup_* 2>/dev/null | tail -n 1)

if [ -n "$LATEST_BACKUP" ]; then
    echo -e "${BLUE}>>> Найден бэкап: $LATEST_BACKUP${NC}"
    read -p "Восстановить файлы из этого бэкапа? (y/n): " confirm
    if [[ $confirm == [yY] ]]; then
        cp -r "$LATEST_BACKUP"/* "$CONFIG_DIR/"
        echo -e "${BLUE}>>> Файлы восстановлены.${NC}"
    fi
fi

echo -e "${RED}>>> Готово. Система очищена от симлинков.${NC}"