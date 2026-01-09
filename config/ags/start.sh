#!/bin/bash

# Сборка
esbuild app.ts --bundle --outfile=main.js --format=esm "--external:gi://*"

if [ $? -eq 0 ]; then
    echo "✅ Сборка завершена"
    
    # Экспортируем переменные для всех дочерних процессов
    export GDK_BACKEND=wayland
    export WAYLAND_DISPLAY=wayland-1 # Укажи тот, что выдает echo
    export GI_TYPELIB_PATH="/usr/lib/astal:/usr/lib/girepository-1.0:$GI_TYPELIB_PATH"
    
    echo "🚀 Запуск (Backend: $GDK_BACKEND)..."
    gjs -m main.js
else
    echo "❌ Ошибка при сборке"
    exit 1
fi