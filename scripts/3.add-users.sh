#!/bin/bash

NEW_USER="mariglen"
PASSWORD="mariglen@2025!!"
SSH_KEY="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC5h6PLoDg2/cY6v8/uhdVFuD8HIZB7aAb0xtMLq8edTpGgfa8uVq52On1r2kCoYCQCWdwqv1tqw7C4nszQoU8N/fzc2LMJlBlVT5AoHFIvJjEp/f+rT0xrK7LcP4YLzF6mboA2qYGCx3RC/PiTTV7Z/GtNadmaoikRKzCxEMV18Ecd+pl2BUrLgQuYVQbwXqVYGMRcaoOwcbUrT45z1WO77FreI+nFOoXGLMSMuGwFd1GYeBDdQOToeM6+CdeRycLsgI+MFpz1jqd42oYsYBIkx9FI3HXWky/I+YImZCewplE6M7CHqBUpYQLHZwlSPcUwYgUmOUsPbWzEApLUOIZIYFIaeZOiPcYFrSE5TqJErd4r53OU+FCd87LYtVcZyjqQ+KDJKxcsR0Cj1mI7OqkuAai/cDyhuOGv2oZqvlgb+8qTgwfV4tZXRsGJG9KzGuR40tBy8oQ4M/4+5BuJYJKd13j8rskTb1/brAz9h0dHFK43helUxoTG7e4XwPpH1SgepwcqOqlux/g+s5knWVLSVIg6TinosU2vyPx7f+AJd8CCMjz1PCfplq0HGlBX9g2ZdpE3f95x3sDy9A12L+a443/0fGMw8lvBLeQ9EVfMHVNjGHuDRZPG0fNusq41kxyTKHSNh9qQZmQEuM4m4STL0f8mhikh+OseIj03Raq5AQ== mariglen@DESKTOP-B4V8RQL"
EMAIL="mcullhaj43@gmail.com"
SUDOERS_LINE="$NEW_USER ALL=(ALL:ALL) NOPASSWD: ALL"
# SUDOERS_LINE="$NEW_USER ALL=(ALL:ALL) ALL" // this is still superuser but need to enter paswd for sudo actions

set -e

if id "$NEW_USER" >/dev/null 2>&1; then
  echo "User $NEW_USER already exists."
else
  adduser --disabled-password --gecos "" "$NEW_USER"
  echo "$NEW_USER:$PASSWORD" | chpasswd
  echo "User $NEW_USER created with password set."
fi

usermod -aG sudo "$NEW_USER"
echo "User $NEW_USER added to sudo group."

SUDOERS_FILE="/etc/sudoers"
if grep -Fx "$SUDOERS_LINE" "$SUDOERS_FILE" >/dev/null; then
  echo "Sudoers entry for $NEW_USER already exists."
else
  echo "$SUDOERS_LINE" | tee -a "$SUDOERS_FILE" >/dev/null
  echo "Sudoers entry for $NEW_USER added."
fi

su - "$NEW_USER" -c "
  mkdir -p ~/.ssh
  chmod 700 ~/.ssh
  echo '$SSH_KEY' > ~/.ssh/authorized_keys
  chmod 600 ~/.ssh/authorized_keys
  ssh-keygen -t rsa -b 4096 -C '$EMAIL' -f ~/.ssh/id_rsa -N ''
"
echo "SSH setup for $NEW_USER completed."

chown -R "$NEW_USER:$NEW_USER" "/home/$NEW_USER/.ssh"
echo "Ownership of .ssh directory set to $NEW_USER."

systemctl restart ssh
echo "SSH service restarted."

echo "Automation completed successfully."