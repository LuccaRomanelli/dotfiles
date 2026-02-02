#!/bin/bash

# Script para instalar driver NVIDIA legado (470xx)
# Necessário para GPUs antigas como GeForce 840M, GTX 700/600 series, etc.
# O driver nvidia-open-dkms só suporta GPUs Turing (RTX 2000) ou mais novas.

set -e

echo "=== Instalação do Driver NVIDIA Legado (470xx) ==="
echo ""
echo "Este script irá:"
echo "  1. Remover o driver nvidia-open-dkms (se instalado)"
echo "  2. Instalar o driver legado nvidia-470xx-dkms do AUR"
echo ""
read -p "Continuar? [y/N] " -n 1 -r
echo ""

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Cancelado."
    exit 0
fi

echo ""
echo ">>> Removendo driver nvidia-open (se existir)..."
sudo pacman -Rns --noconfirm nvidia-open-dkms nvidia-utils lib32-nvidia-utils 2>/dev/null || true

echo ""
echo ">>> Instalando driver nvidia-470xx do AUR..."
yay -S --needed nvidia-470xx-dkms nvidia-470xx-utils

echo ""
echo "=== Instalação concluída! ==="
echo ""
echo "Reinicie o sistema para carregar o novo driver:"
echo "  sudo reboot"
echo ""
echo "Após o reboot, verifique com: nvidia-smi"
