#!/bin/sh

set -eu

ARCH=$(uname -m)

echo "Installing build dependency expac..."
echo "---------------------------------------------------------------"
pacman -Syu --noconfirm expac

echo "Installing package and its dependencies..."
echo "---------------------------------------------------------------"
pacman -Syu --noconfirm gnome-text-editor
pacman -Syu --needed --noconfirm --asdeps $(expac -Ss '%o' enchant)

echo "Installing debloated packages..."
echo "---------------------------------------------------------------"
get-debloated-pkgs --add-common --prefer-nano
