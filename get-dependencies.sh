#!/bin/sh

set -eux

DEBLOATED_PKGS_INSTALLER="https://raw.githubusercontent.com/pkgforge-dev/Anylinux-AppImages/refs/heads/main/useful-tools/get-debloated-pkgs.sh"

echo "Installing build dependencies for sharun & AppImage integration..."
echo "---------------------------------------------------------------"
pacman -Syu --noconfirm \
	base-devel \
	curl \
	desktop-file-utils \
	git \
	libxtst \
	wget \
	xorg-server-xvfb \
	zsync \
    expac
echo "Installing the app & it's dependencies..."
echo "---------------------------------------------------------------"
pacman -Syu --noconfirm \
	gnome-text-editor
echo "Installing optional dependencies for 'enchant' spelling library automatically"
pacman -Syu --needed --noconfirm --asdeps $(expac -Ss '%o' enchant)

echo "Installing debloated packages..."
echo "---------------------------------------------------------------"
wget --retry-connrefused --tries=30 "$DEBLOATED_PKGS_INSTALLER" -O ./get-debloated-pkgs.sh
chmod +x ./get-debloated-pkgs.sh
./get-debloated-pkgs.sh libxml2-mini mesa-nano gtk4-mini librsvg-mini

echo "Extracting the app version into a version file"
echo "---------------------------------------------------------------"
pacman -Q gnome-text-editor | awk '{print $2; exit}' > ~/version
