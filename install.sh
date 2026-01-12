#!/bin/bash

# --- НАСТРОЙКИ ЦВЕТОВ ---
BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m'

# Точное определение пути дотфайлов (абсолютный путь)
DOTFILES_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
BACKUP_DIR="$HOME/.config_backup_$(date +%Y%m%d_%H%M%S)"

DEPENDENCIES=("hyprland" "alacritty" "waybar" "swaync" "rofi" "matugen" "pamixer" "brightnessctl" "eww" "wlogout")
CONFIG_FOLDERS=("hypr" "alacritty" "waybar" "swaync" "rofi" "matugen" "eww" "wlogout")

echo -e "${BLUE}>>> Начало установки. Источник: $DOTFILES_DIR${NC}"

# 1. Проверка пакетов
echo -e "${BLUE}>>> Проверка пакетов...${NC}"
for pkg in "${DEPENDENCIES[@]}"; do
    if pacman -Qs "$pkg" > /dev/null; then
        echo -e "${GREEN}[OK]${NC} $pkg"
    else
        echo -e "${YELLOW}[!]${NC} Пакет $pkg не найден.${NC}"
    fi
done

# 2. Линковка стандартных папок
echo -e "${BLUE}>>> Настройка конфигураций в ~/.config...${NC}"
mkdir -p "$HOME/.config"

for folder in "${CONFIG_FOLDERS[@]}"; do
    TARGET="$HOME/.config/$folder"
    SOURCE="$DOTFILES_DIR/config/$folder"

    if [ -d "$SOURCE" ]; then
        # Если цель уже существует (файл, папка или битая ссылка)
        if [ -e "$TARGET" ] || [ -L "$TARGET" ]; then
            # Если это реальная папка (не ссылка) — делаем бэкап
            if [ -d "$TARGET" ] && [ ! -L "$TARGET" ]; then
                mkdir -p "$BACKUP_DIR"
                echo -e "${YELLOW}>>> Бэкап папки $folder в $BACKUP_DIR${NC}"
                mv "$TARGET" "$BACKUP_DIR/"
            else
                # Если это старая ссылка или файл — удаляем решительно
                rm -rf "$TARGET"
            fi
        fi
        
        # Создаем симлинк. Флаг -v покажет результат.
        ln -snf "$SOURCE" "$TARGET"
        
        if [ -L "$TARGET" ]; then
            echo -e "${GREEN}>>> Ссылка создана: .config/$folder -> $(readlink $TARGET)${NC}"
        else
            echo -e "${RED}>>> ОШИБКА создания ссылки для $folder${NC}"
        fi
    fi
done

# 3. ЛИНКОВКА VS CODE (Code - OSS)
echo -e "${BLUE}>>> Настройка VS Code (Code - OSS)...${NC}"
VS_SOURCE_DIR="$DOTFILES_DIR/config/Code - OSS/User"
VS_TARGET_DIR="$HOME/.config/Code - OSS/User"

if [ -d "$VS_SOURCE_DIR" ]; then
    mkdir -p "$VS_TARGET_DIR"
    for file in "settings.json" "keybindings.json"; do
        S_FILE="$VS_SOURCE_DIR/$file"
        T_FILE="$VS_TARGET_DIR/$file"
        
        if [ -f "$S_FILE" ]; then
            if [ -e "$T_FILE" ] || [ -L "$T_FILE" ]; then
                if [ -f "$T_FILE" ] && [ ! -L "$T_FILE" ]; then
                    mkdir -p "$BACKUP_DIR/vscode"
                    mv "$T_FILE" "$BACKUP_DIR/vscode/"
                else
                    rm -f "$T_FILE"
                fi
            fi
            ln -snf "$S_FILE" "$T_FILE"
            echo -e "${GREEN}>>> Ссылка создана: Code - OSS/User/$file${NC}"
        fi
    done
fi

# 4. Установка прав и линковка обоев (без изменений, но с проверкой)
echo -e "${BLUE}>>> Установка прав на скрипты и настройка обоев...${NC}"
[ -d "$HOME/.config/hypr/scripts" ] && chmod +x "$HOME/.config/hypr/scripts/"*.sh

WALL_SOURCE="$DOTFILES_DIR/wallpapers"
WALL_TARGET="$HOME/Pictures/Wallpapers"
if [ -d "$WALL_SOURCE" ]; then
    mkdir -p "$HOME/Pictures"
    rm -rf "$WALL_TARGET" # Удаляем старую ссылку/папку перед линковкой
    ln -snf "$WALL_SOURCE" "$WALL_TARGET"
    echo -e "${GREEN}>>> Обои слинкованы: $WALL_TARGET${NC}"
fi

echo -e "\n${BLUE}>>> Установка завершена!${NC}"