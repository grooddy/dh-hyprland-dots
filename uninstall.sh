#!/bin/bash

RED='\033[0;31m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
NC='\033[0m'

CONFIG_DIR="$HOME/.config"
# Добавил eww, так как он теперь часть твоего сетапа
CONFIGS=("hypr" "alacritty" "waybar" "swaync" "rofi" "eww")
WALL_TARGET="$HOME/Pictures/Wallpapers"

echo -e "${RED}>>> Удаление симлинков дотфайлов...${NC}"

# 1. Удаление ссылок на конфиги
for folder in "${CONFIGS[@]}"; do
    TARGET="$CONFIG_DIR/$folder"
    
    if [ -L "$TARGET" ]; then
        rm "$TARGET"
        echo -e "${RED}--- Удалена ссылка: .config/$folder${NC}"
    elif [ -d "$TARGET" ] && [ ! -L "$TARGET" ]; then
        echo -e "${YELLOW}--- Пропуск: .config/$folder является реальной папкой, а не ссылкой.${NC}"
    fi
done

# 2. Удаление ссылки на обои
if [ -L "$WALL_TARGET" ]; then
    rm "$WALL_TARGET"
    echo -e "${RED}--- Удалена ссылка на обои: $WALL_TARGET${NC}"
fi

# 3. Поиск и восстановление последнего бэкапа
LATEST_BACKUP=$(ls -d $HOME/.config_backup_* 2>/dev/null | sort -r | head -n 1)

if [ -n "$LATEST_BACKUP" ]; then
    echo -e "\n${BLUE}>>> Найден бэкап: $LATEST_BACKUP${NC}"
    read -p "Восстановить файлы из этого бэкапа? (y/n): " confirm
    if [[ $confirm == [yY] || $confirm == [дД] ]]; then
        # Копируем содержимое бэкапа обратно в .config
        cp -af "$LATEST_BACKUP"/. "$CONFIG_DIR/"
        echo -e "${BLUE}>>> Файлы восстановлены из бэкапа.${NC}"
        
        # Опционально: спрашиваем, удалить ли папку бэкапа после восстановления
        read -p "Удалить папку бэкапа теперь? (y/n): " rm_backup
        if [[ $rm_backup == [yY] ]]; then
            rm -rf "$LATEST_BACKUP"
            echo -e "${RED}>>> Папка бэкапа удалена.${NC}"
        fi
    fi
fi

echo -e "${RED}>>> Готово. Система очищена от симлинков.${NC}"