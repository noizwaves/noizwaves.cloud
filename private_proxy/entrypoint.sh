#!/usr/bin/env sh

# Ensure key permissions are good
chmod 600 /key

# Show container's IP address
echo '# Network interfaces'
ip -brief addr show

# Set up tunnel
echo '# Setting up tunnel'
ssh -4 -T -i /root/.ssh/private_key -o "StrictHostKeyChecking=no" -N -L 0.0.0.0:443:127.0.0.1:${REMOTE_SSL_PORT} "${REMOTE_USER}"@"${REMOTE_HOST}"
echo '# Tunnel closed'