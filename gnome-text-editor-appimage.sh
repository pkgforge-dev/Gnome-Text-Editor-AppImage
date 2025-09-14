#!/bin/sh

set -eux

ARCH="$(uname -m)"
PACKAGE=gnome-text-editor
URUNTIME="https://raw.githubusercontent.com/pkgforge-dev/Anylinux-AppImages/refs/heads/main/useful-tools/uruntime2appimage.sh"
SHARUN="https://raw.githubusercontent.com/pkgforge-dev/Anylinux-AppImages/refs/heads/main/useful-tools/quick-sharun.sh"

VERSION=$(pacman -Q "$PACKAGE" | awk 'NR==1 {print $2; exit}')
[ -n "$VERSION" ] && echo "$VERSION" > ~/version

# Variables used by quick-sharun
export UPINFO="gh-releases-zsync|${GITHUB_REPOSITORY%/*}|${GITHUB_REPOSITORY#*/}|latest|*$ARCH.AppImage.zsync"
export OUTNAME="$PACKAGE"-"$VERSION"-anylinux-"$ARCH".AppImage
export DESKTOP=/usr/share/applications/org.gnome.TextEditor.desktop
export ICON=/usr/share/icons/hicolor/scalable/apps/org.gnome.TextEditor.svg
export DEPLOY_OPENGL=1
export STARTUPWMCLASS=gnome-text-editor # For Wayland, this is 'org.gnome.TextEditor', so this needs to be changed in desktop file manually by the user in that case until some potential automatic fix exists for this

# DEPLOY ALL LIBS
wget --retry-connrefused --tries=30 "$SHARUN" -O ./quick-sharun
chmod +x ./quick-sharun
./quick-sharun /usr/bin/gnome-text-editor

## Copy missing spelling libs
cp -v /usr/lib/lib*spell* ./AppDir/shared/lib/
cp -v /usr/lib/libvoikko* ./AppDir/shared/lib/

## Generate new lib path list
./AppDir/sharun -g

## Copy help files for Help section to work
langs=$(find /usr/share/help/*/gnome-text-editor/ -type f | awk -F'/' '{print $5}' | sort | uniq)
for lang in $langs; do
  mkdir -p ./AppDir/share/help/$lang/gnome-text-editor/
  cp -vr /usr/share/help/$lang/gnome-text-editor/* ./AppDir/share/help/$lang/gnome-text-editor/
done

## Further debloat locale
find ./AppDir/share/locale -type f ! -name '*glib*' ! -name '*gnome-text-editor*' -delete

## Set gsettings to save to keyfile, instead to dconf
echo "GSETTINGS_BACKEND=keyfile" >> ./AppDir/.env

# MAKE APPIMAGE WITH URUNTIME
wget --retry-connrefused --tries=30 "$URUNTIME" -O ./uruntime2appimage
chmod +x ./uruntime2appimage
./uruntime2appimage
