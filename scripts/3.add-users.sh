#!/bin/bash

NEW_USER="ermal5"
PASSWORD="ermal5#############!!!!!!"
SSH_KEY="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDH3f5WxBxQUWcfDGErpqbBgC08cPVzgnI4sizDtYsHSbAcp9O04gfG+HmI6C9rozBJrXRN6V0VKt15CV8rrO6OAv6gArRx9Uil5JpneHmfSB9UnunL4RS7crfrXGcs4980+BiZt16/ropS+i6ECUmS1Kjgsz+ItdhCEhltsWLxBSPKx1L1jjpZNStINVqtV4MCpnzvwFmcYLZoyngpWMuuj4F5Px+dquX8TJ1EgFoXJTB52z3BVmZiWZxlMDYFXLIgR+kjqnJ5PpEEtpmfKLFbSCPHqOZnuhmtXc/Eeb88cXNkDc5T/0vf6S9o1QufO2KbxAfkVjtzobw8bpRfChT1l3K/B5/vg7ij3B3lubLTBvQRM2TZUyg3fY94Y8tC12P+mewsn4C0TyrNxlsC0nVGTthoyZeif9p/NRXWQgVx1mEO2zDXNHs30EQsIyzeqd5kJmDUbHyRUZS+iD/tuWgduINl5TZrQ4JgFKZ4TRPEC571TG7yR5Cu0m6jqyNOt1f0cb12YAvOE7IWDm7wogiqmGfamVGIqF7w+uw+BBPZS42nGQ9UATt9+CU1AX2emGT+L0f+/aAovNCtQBWQOkBoLrjGMnMb3ErnEW78Td8fWfM5fdvLHH6ELNXNU/qtjY4b9nfXbwCI8zKtNkrcmPECoL2jrmOTg+Wwl6aQecTQhw== ermal2@LAPTOP-HFC8LI3B"
EMAIL="ermal.aliraj@gmail.com"
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