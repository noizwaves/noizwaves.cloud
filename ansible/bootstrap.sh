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

# accessible using my ssh keys
mkdir -p /home/cloud/.ssh
echo "ssh-rsa AAAAB4NzaC1yc2EAAAADAQABAAACAQDVACKaRKzpxRiXxxToMkAZcycfDVJkqhDS+Bf1GLHHiRYnv0pGR4cgrNHb+aQgpBIibDIR5BJXRJhifhK7Nj8Dc6KkVVAtys+308FQYiM7AeUvFOW8HkTdOgEFv64o/YsyRaLb1y7GkWKDGe1NvLIiRRjg3mHUbQHCnla1zKyW42S9KLm/zFg3bCtW7OtA6ptcgQVNT4XKDmjI6wDgxdq4Hjdy4500QxjM6529QBCSK4/UF3PxcxanizeKt3p/Bf6VzSfz2xJqdRxgViPHA5tYAOM4db9yIoOocJAs4g5ju2ebgbOcQA/4G89emxP87lww30HHHwV8xhsVDH/dQr+BHC4BBkzvzH2+2fDTZb9/5TY+s/Ezp5SXfQmfbvbl324e3ast0lGAP27l8h9cOlL8SF13ZKTXveyb9sLeJnj0iBaZjX5G4JO/Be4TK2z6Sj7v+M7+AixJ0UFc5yP7qvKzOlXSLrkhvgqOi19xix7w9y71gDLQakwmeqrtoQI+CzFJKN2DcKUcB7lYdcb7iAFjhTNJJZdCzav2XCN2H+Ybhgwk6gdagoh6Z3I0TWhq9NMOt8gRpYatK2zKVzLtoi+w+ueKL6LEvaUWWoHwZuTnvIGkWN4B2eaqu25Wr0HHzleGHLqb+5e8ziwcX6UN5/LLA8C6cKSn1yPlPYd4gUEpVw== adam@popintosh
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIL9jVkxs5XkdNRaK6d9K3NP0MYczCZySKYJVirJIlLmX adam.neumann@gusto.com
" > /home/cloud/.ssh/authorized_keys
chown -R cloud:cloud /home/cloud/.ssh

# and with Tailscale
curl -fsSL https://tailscale.com/install.sh | sh
