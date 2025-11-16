#!/bin/sh

set -eu

ARCH=$(uname -m)
VERSION=$(pacman -Q gnome-text-editor | awk '{print $2; exit}')
export ARCH VERSION
export OUTPATH=./dist
export UPINFO="gh-releases-zsync|${GITHUB_REPOSITORY%/*}|${GITHUB_REPOSITORY#*/}|latest|*$ARCH.AppImage.zsync"
export ICON=/usr/share/icons/hicolor/scalable/apps/org.gnome.TextEditor.svg
export DESKTOP=/usr/share/applications/org.gnome.TextEditor.desktop
export DEPLOY_OPENGL=1
export STARTUPWMCLASS=gnome-text-editor # For Wayland, this is 'org.gnome.TextEditor', so this needs to be changed in desktop file manually by the user in that case until some potential automatic fix exists for this

# Trace and deploy all files and directories needed for the application (including binaries, libraries and others)
quick-sharun /usr/bin/gnome-text-editor

## Copy help files for Help section to work
langs=$(find /usr/share/help/*/gnome-text-editor/ -type f | awk -F'/' '{print $5}' | sort | uniq)
for lang in $langs; do
  mkdir -p ./AppDir/share/help/$lang/gnome-text-editor/
  cp -vr /usr/share/help/$lang/gnome-text-editor/* ./AppDir/share/help/$lang/gnome-text-editor/
done

# Turn AppDir into AppImage
quick-sharun --make-appimage
