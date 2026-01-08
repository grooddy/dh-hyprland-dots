# <img src="https://github.com/user-attachments/assets/75080517-5e01-443b-871d-15f5c9e4726d" width="35" height="35" style="vertical-align:middle;"> Hyprland macOS-style Dotfiles

![Stars](https://img.shields.io/github/stars/grooddy/dh-hyprland-dots?style=for-the-badge&color=white)
![License](https://img.shields.io/github/license/grooddy/dh-hyprland-dots?style=for-the-badge&color=white)
![Platform](https://img.shields.io/badge/Platform-Arch%20Linux-blue?style=for-the-badge&logo=arch-linux)

> **Эстетика macOS в сочетании с мощностью Hyprland.** Минималистичная, плавная и функциональная конфигурация на базе CachyOS.

---

## 📸 Скриншоты

<p align="center">
  <img src="./preview.png" alt="Desktop Preview" width="90%">
</p>

---

## ✨ Основные особенности

* **🍏 Apple-style Physics:** Кастомные кривые Безье (`apple_decel`), воссоздающие инерцию и "вес" окон.
* **❄️ Frosted Glass:** Глубокий эффект размытия (4 прохода) с мягкими тенями.
* **🚀 Smooth Workspaces:** Горизонтальное переключение рабочих столов с динамическим замедлением.
* **🎨 Dynamic Colors:** Интеграция с `pywal` для адаптации цветов под обои.
* **🔔 Center Stage:** SwayNC в качестве центра уведомлений и быстрых настроек.

---

## 🛠 Компоненты системы

| Компонент | Программа |
| :--- | :--- |
| **ОС** | [CachyOS](https://cachyos.org/) (Arch-based) |
| **Терминал** | [Alacritty](https://alacritty.org/) |
| **Панель** | [Waybar](https://github.com/Alexays/Waybar) |
| **Лаунчер** | [Rofi-wayland](https://github.com/lbonn/rofi-wayland) |
| **Уведомления** | [SwayNC](https://github.com/ErikReider/SwayNotificationCenter) |
| **Шрифт** | JetBrains Mono Nerd Font |
| **Док** | [nwg-dock-hyprland](https://github.com/nwg-piotr/nwg-dock-hyprland) |

---

## 🚀 Быстрая установка

### 1. Склонируйте репозиторий
git clone [https://github.com/grooddy/dh-hyprland-dots.git](https://github.com/grooddy/dh-hyprland-dots.git) ~/dotfiles
cd ~/dotfiles'''
### 2. Запустите инсталлятор
chmod +x install.sh
./install.sh
⌨️ Горячие клавиши

    SUPER + SPACE — Поиск приложений (Rofi)

    SUPER + Enter — Терминал (Alacritty)

    SUPER + N — Центр уведомлений (SwayNC)

    SUPER + Q — Закрыть активное окно

    SUPER + L — Блокировка экрана (Hyprlock)

    PrintScreen — Скриншот области (Grim + Slurp)
📦 Зависимости
Для корректной работы установите следующие пакеты: hyprland alacritty waybar swaync rofi-wayland ttf-jetbrains-mono-nerd swappy grim slurp cliphist nwg-dock-hyprland
<p align="center"> Сделано с ❤️ для сообщества Linux. </p>