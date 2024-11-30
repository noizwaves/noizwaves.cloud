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

# and with Tailscale
curl -fsSL https://tailscale.com/install.sh | sh
