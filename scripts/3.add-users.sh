#!/bin/bash
set -e

declare -A USERS

USERS[mariglen]="mariglen@2025!!|mcullhaj43@gmail.com|ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC5h6PLoDg2/cY6v8/uhdVFuD8HIZB7aAb0xtMLq8edTpGgfa8uVq52On1r2kCoYCQCWdwqv1tqw7C4nszQoU8N/fzc2LMJlBlVT5AoHFIvJjEp/f+rT0xrK7LcP4YLzF6mboA2qYGCx3RC/PiTTV7Z/GtNadmaoikRKzCxEMV18Ecd+pl2BUrLgQuYVQbwXqVYGMRcaoOwcbUrT45z1WO77FreI+nFOoXGLMSMuGwFd1GYeBDdQOToeM6+CdeRycLsgI+MFpz1jqd42oYsYBIkx9FI3HXWky/I+YImZCewplE6M7CHqBUpYQLHZwlSPcUwYgUmOUsPbWzEApLUOIZIYFIaeZOiPcYFrSE5TqJErd4r53OU+FCd87LYtVcZyjqQ+KDJKxcsR0Cj1mI7OqkuAai/cDyhuOGv2oZqvlgb+8qTgwfV4tZXRsGJG9KzGuR40tBy8oQ4M/4+5BuJYJKd13j8rskTb1/brAz9h0dHFK43helUxoTG7e4XwPpH1SgepwcqOqlux/g+s5knWVLSVIg6TinosU2vyPx7f+AJd8CCMjz1PCfplq0HGlBX9g2ZdpE3f95x3sDy9A12L+a443/0fGMw8lvBLeQ9EVfMHVNjGHuDRZPG0fNusq41kxyTKHSNh9qQZmQEuM4m4STL0f8mhikh+OseIj03Raq5AQ== mariglen@DESKTOP-B4V8RQL"
USERS[ermal]="ermal@password@EaT377|ermal.aliraj@gmail.com|ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDH3f5WxBxQUWcfDGErpqbBgC08cPVzgnI4sizDtYsHSbAcp9O04gfG+HmI6C9rozBJrXRN6V0VKt15CV8rrO6OAv6gArRx9Uil5JpneHmfSB9UnunL4RS7crfrXGcs4980+BiZt16/ropS+i6ECUmS1Kjgsz+ItdhCEhltsWLxBSPKx1L1jjpZNStINVqtV4MCpnzvwFmcYLZoyngpWMuuj4F5Px+dquX8TJ1EgFoXJTB52z3BVmZiWZxlMDYFXLIgR+kjqnJ5PpEEtpmfKLFbSCPHqOZnuhmtXc/Eeb88cXNkDc5T/0vf6S9o1QufO2KbxAfkVjtzobw8bpRfChT1l3K/B5/vg7ij3B3lubLTBvQRM2TZUyg3fY94Y8tC12P+mewsn4C0TyrNxlsC0nVGTthoyZeif9p/NRXWQgVx1mEO2zDXNHs30EQsIyzeqd5kJmDUbHyRUZS+iD/tuWgduINl5TZrQ4JgFKZ4TRPEC571TG7yR5Cu0m6jqyNOt1f0cb12YAvOE7IWDm7wogiqmGfamVGIqF7w+uw+BBPZS42nGQ9UATt9+CU1AX2emGT+L0f+/aAovNCtQBWQOkBoLrjGMnMb3ErnEW78Td8fWfM5fdvLHH6ELNXNU/qtjY4b9nfXbwCI8zKtNkrcmPECoL2jrmOTg+Wwl6aQecTQhw== ermal2@LAPTOP-HFC8LI3B"

for NEW_USER in "${!USERS[@]}"; do
  IFS='|' read -r PASSWORD EMAIL SSH_KEY <<< "${USERS[$NEW_USER]}"
  SUDOERS_LINE="$NEW_USER ALL=(ALL:ALL) NOPASSWD: ALL"
  SUDOERS_FILE="/etc/sudoers"

  if id "$NEW_USER" >/dev/null 2>&1; then
    echo "User $NEW_USER already exists."
  else
    adduser --disabled-password --gecos "" "$NEW_USER"
    echo "$NEW_USER:$PASSWORD" | chpasswd
    echo "User $NEW_USER created with password set."
  fi

  usermod -aG sudo "$NEW_USER"
  echo "User $NEW_USER added to sudo group."

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

  chown -R "$NEW_USER:$NEW_USER" "/home/$NEW_USER/.ssh"
  echo "SSH setup for $NEW_USER completed."
  echo ""
done

systemctl restart ssh

echo "Automation completed successfully."