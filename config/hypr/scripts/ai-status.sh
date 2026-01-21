#!/bin/bash
# Путь: ~/.config/hypr/scripts/ai-status.sh

DOCKER_CONTAINER="open-webui"
OLLAMA_UNIT="ollama.service"

# Функция проверки Docker
is_docker_running() {
    docker inspect -f '{{.State.Running}}' "$DOCKER_CONTAINER" 2>/dev/null | grep -q 'true'
}

# Функция проверки Ollama
is_ollama_running() {
    systemctl is-active --quiet "$OLLAMA_UNIT"
}

case "$1" in
    --toggle-ollama)
        if is_ollama_running; then
            sudo systemctl stop "$OLLAMA_UNIT" && notify-send -i "ollama" "AI" "Ollama Stopped"
        else
            sudo systemctl start "$OLLAMA_UNIT" && notify-send -i "ollama" "AI" "Ollama Started"
        fi
        ;;
    --toggle-docker)
        if is_docker_running; then
            docker stop "$DOCKER_CONTAINER" && notify-send -i "docker" "Docker" "Open-WebUI Stopped"
        else
            docker start "$DOCKER_CONTAINER" && notify-send -i "docker" "Docker" "Open-WebUI Started"
        fi
        ;;
    *)
        # Логика для Waybar
        O_ICON="󱙺" && O_CLASS="stopped"
        D_ICON="󰚩" && D_CLASS="stopped"
        
        is_ollama_running && O_ICON="󰚩" && O_CLASS="running"
        is_docker_running && D_ICON="󰚩" && D_CLASS="running"

        # Если хотя бы один запущен - подсвечиваем весь модуль как running
        FINAL_CLASS="stopped"
        if [ "$O_CLASS" == "running" ] || [ "$D_CLASS" == "running" ]; then
            FINAL_CLASS="running"
        fi

        echo "{\"text\": \"Ollama: $O_ICON | WebUI: $D_ICON\", \"class\": \"$FINAL_CLASS\", \"tooltip\": \"ЛКМ: Ollama | ПКМ: Open-WebUI\"}"
        ;;
esac