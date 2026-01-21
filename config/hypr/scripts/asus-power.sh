# Защита от спама кнопкой
LOCKFILE="/tmp/asus_power.lock"
[ -f "$LOCKFILE" ] && exit 0
touch "$LOCKFILE"
trap "rm -f $LOCKFILE" EXIT

# Получаем данные за один проход, чтобы не дергать систему трижды
RAW_INFO=$(asusctl profile get | grep 'Active profile')
PROFILE=$(echo "$RAW_INFO" | awk '{print $NF}')

# Обновляем виджеты SwayNC БЕЗ перезагрузки всего центра управления
# Мы просто меняем текст меток через динамический payload
swaync-client -pd "{\"custom-power\": {\"text\": \"PWR: $PROFILE\"}}" > /dev/null 2>&1

# Переключаем профиль и даем контроллеру чуть больше времени (ASUS бывает медленным)
asusctl profile next > /dev/null
sleep 0.2

# Отправляем уведомление
notify-send -a "Asus System" -i "battery-charging" "Режим питания" "Активен: $PROFILE"

# Сигнал Waybar обновить отображение (если там есть модуль)
pkill -SIGUSR2 waybar