#!/bin/bash
set -e

apt_fast_installation() {
  if ! type aria2c >/dev/null 2>&1; then
    sudo apt-get update
    sudo apt-get install -y aria2
  fi

  wget https://raw.githubusercontent.com/Hakimi0804/apt-fast/master/apt-fast -O "${PREFIX%/usr}/usr/local/bin/apt-fast"
  chmod +x "${PREFIX%/usr}/usr/local/bin/apt-fast"
  if ! [[ -f "${PREFIX}/etc/apt-fast.conf" ]]; then
    wget https://raw.githubusercontent.com/Hakimi0804/apt-fast/master/apt-fast.conf -O "${PREFIX}/etc/apt-fast.conf"
  fi
}


if [[ -n "$PREFIX" ]]; then
  # We're in termux

  remove=false
  [ ! -d "${PREFIX%/usr}"/usr/local/bin ] && { mkdir -p "${PREFIX%/usr}/usr/local/bin"; remove=true; }
  apt_fast_installation
  mv "${PREFIX%/usr}/usr/local/bin/apt-fast" "${PREFIX}/bin"

  if [[ "$remove" = true ]]; then
  	rm -rf "${PREFIX%/usr}/usr/local/bin"
  fi

  termux-fix-shebang "$(command -v apt-fast)"

  exit 0
fi

if [[ "$EUID" -eq 0 ]]; then
  apt_fast_installation
else
  type sudo >/dev/null 2>&1 || { echo "sudo not installed, change into root context" >&2; exit 1; }

  DECL="$(declare -f apt_fast_installation)"
  sudo bash -c "$DECL; apt_fast_installation"
fi
