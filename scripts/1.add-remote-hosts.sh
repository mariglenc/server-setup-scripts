#!/bin/bash

cp /etc/hosts /etc/hosts.bak
echo "Backed up /etc/hosts to /etc/hosts.bak"

# Host entries to add (IP and hostname pairs)
hosts=(
  "95.211.222.182 testServer"
  "95.211.140.132 prdServer"
  "18.207.230.234 devServerAws"
)
for entry in "${hosts[@]}"; do
  ip=$(echo "$entry" | awk '{print $1}')
  hostname=$(echo "$entry" | awk '{print $2}')
  if ! grep -qE "^\s*$ip\s+$hostname\b" /etc/hosts; then
    echo "$ip $hostname" >> /etc/hosts
    echo "Added $ip $hostname to /etc/hosts"
  else
    echo "Entry $ip $hostname already exists in /etc/hosts"
  fi
done

echo "Configuration complete."
