#! /usr/bin/env bash
# shellcheck disable=SC2010

set -eux

pacman -U --noconfirm "$1"
ls -l /home/archuser/.eteks/sweethome3d/furniture/ || true
ls -l /home/archuser/.eteks/sweethome3d/textures/ || true

if ls -l /home/archuser/.eteks/sweethome3d/furniture/ | grep '\*'; then
  exit 128
fi

if ls -l /home/archuser/.eteks/sweethome3d/textures/ | grep '\*'; then
  exit 128
fi
