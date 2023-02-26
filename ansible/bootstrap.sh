#!/usr/bin/env bash
set -e

# cloud user
if ! id cloud &>/dev/null; then
  useradd \
    -s /bin/bash \
    -d /home/cloud \
    -m \
    -G sudo \
    cloud
fi

# cloud user can sudo
echo "cloud   ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/cloud

# with SSH server installed
apt-get update
apt-get install -y openssh-server

# and with Tailscale
curl -fsSL https://tailscale.com/install.sh | sh
