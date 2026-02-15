#!/bin/bash

# Colores para la terminal
BOLD='\033[1m'
CYAN='\033[0;36m'
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${CYAN}${BOLD}>>> Iniciando Instalador Universal de dwm + Autostart + Desktop Entry${NC}"

# 1. Función para instalar dependencias según la Distro
install_deps() {
    echo -e "${CYAN}Detectando gestor de paquetes...${NC}"
    if [ -f /etc/arch-release ]; then
        sudo pacman -Syu --needed --noconfirm base-devel libx11 libxft libxinerama xorg-xinit rofi alacritty
    elif [ -f /etc/debian_version ]; then
        sudo apt update && sudo apt install -y build-essential libx11-dev libxft-dev libxinerama-dev xinit rofi alacritty
    elif [ -f /etc/fedora-release ]; then
        sudo dnf groupinstall -y "Development Tools" && sudo dnf install -y libX11-devel libXft-devel libXinerama-devel xinitrc rofi alacritty
    elif [ -f /etc/void-release ]; then
        sudo xbps-install -Sy base-devel libX11-devel libXft-devel libXinerama-devel xinit rofi alacritty
    elif [ -f /etc/alpine-release ]; then
        sudo apk add build-base libx11-dev libxft-dev libxinerama-dev xinit rofi alacritty
    elif [ -f /etc/os-release ] && grep -q "opensuse" /etc/os-release; then
        sudo zypper install -t pattern devel_basis && sudo zypper install -y libX11-devel libXft-devel libXinerama-devel xinit rofi alacritty
    else
        echo -e "${RED}Distribución no soportada automáticamente.${NC}"
        exit 1
    fi
}

install_deps

# 2. Crear carpetas y autostart.sh
echo -e "${CYAN}Configurando ~/.dwm/autostart.sh...${NC}"
mkdir -p ~/.dwm
if [ ! -f ~/.dwm/autostart.sh ]; then
    cat <<EOF > ~/.dwm/autostart.sh
#!/bin/bash
# Programas que inician con dwm
# feh --bg-fill /ruta/a/imagen.jpg &
# slstatus &
# picom &
EOF
    chmod +x ~/.dwm/autostart.sh
fi

# 3. Compilar e instalar dwm
if [ -d ~/dwm ]; then
    echo -e "${CYAN}Compilando dwm...${NC}"
    cd ~/dwm
    sudo make clean install
else
    echo -e "${RED}Error: No se encontró la carpeta ~/dwm${NC}"
    exit 1
fi

# 4. Crear el archivo .desktop para el Display Manager (DM)
echo -e "${CYAN}Creando entrada para el Display Manager...${NC}"
sudo mkdir -p /usr/share/xsessions
sudo tee /usr/share/xsessions/dwm.desktop > /dev/null <<EOF
[Desktop Entry]
Encoding=UTF-8
Name=DWM Personalizado
Comment=Dynamic Window Manager
Exec=dwm
Icon=dwm
Type=XSession
EOF

echo -e "${GREEN}${BOLD}>>> ¡INSTALACIÓN EXITOSA!${NC}"
echo -e "Ahora puedes cerrar sesión y elegir 'DWM Personalizado' en tu pantalla de login."
