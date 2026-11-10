#!/bin/bash
# Runs inside the image at build time. Everything here is baked into the OS.
set -ouex pipefail

# ---- Packages (system level) ------------------------------------------------
# GUI apps go in as Flatpaks at first boot (see flatpaks.txt); only system
# tools, themes and WinApps dependencies are layered here.
dnf5 install -y \
  kvantum \
  papirus-icon-theme \
  rsms-inter-fonts \
  fish \
  fastfetch \
  freerdp \
  dialog \
  iproute \
  libnotify \
  nmap-ncat \
  podman-compose

# ---- Identity -----------------------------------------------------------------
# Keep ID=fedora so Fedora tooling keeps working; change what users see.
sed -i \
  -e 's/^NAME=.*/NAME="MyDistro"/' \
  -e 's/^PRETTY_NAME=.*/PRETTY_NAME="MyDistro (based on Fedora Atomic)"/' \
  -e 's/^VARIANT=.*/VARIANT="MyDistro"/' \
  -e 's/^VARIANT_ID=.*/VARIANT_ID=mydistro/' \
  /usr/lib/os-release

# Record which variant this is, so the GPU check can point to the right twin
mkdir -p /usr/share/mydistro
HAS_NVIDIA=0
rpm -qa | grep -qE '^(kmod-nvidia|nvidia-driver|akmod-nvidia)' && HAS_NVIDIA=1
cat > /usr/share/mydistro/image.env <<ENV
IMAGE_STANDARD=ghcr.io/${IMAGE_OWNER}/${IMAGE_NAME%-nvidia}:latest
IMAGE_NVIDIA=ghcr.io/${IMAGE_OWNER}/${IMAGE_NAME%-nvidia}-nvidia:latest
HAS_NVIDIA=${HAS_NVIDIA}
ENV

# ---- Services -------------------------------------------------------------------
systemctl enable mydistro-flatpaks.service
systemctl enable mydistro-gpu-check.service
systemctl enable podman.socket
