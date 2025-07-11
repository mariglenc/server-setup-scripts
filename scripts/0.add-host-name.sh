#!/bin/bash

# Set hostname to dev
echo "dev" > /etc/hostname
hostnamectl set-hostname dev
echo "Hostname set to dev"

# Update localhost entry in /etc/hosts
if grep -q "127.0.1.1" /etc/hosts; then
  sed -i 's/127.0.1.1.*/127.0.1.1 dev/' /etc/hosts
  echo "Updated localhost entry in /etc/hosts"
else
  echo "127.0.1.1 dev" >> /etc/hosts
  echo "Added localhost entry for dev in /etc/hosts"
fi

echo "Configuration complete. You may need to reboot for hostname changes to fully take effect."
