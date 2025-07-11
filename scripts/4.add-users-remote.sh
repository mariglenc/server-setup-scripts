#!/bin/bash

REMOTE_USERS=(
  "mariglen@95.211.222.182"
  "mariglen@213.227.135.49"
)

TARGET_USER="jenkins"

PUBLIC_KEYS=(
  "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC23LBU42ca1oKp54alITptcJ8Z+eveHJTWG3X9YaoZ1JcutR9aYuf2WXyJlUnqNbZ/2ThCaka61NX2B4+XZJlav4n8XXoGZ+rUwrhMWDP82lXMD7tDDdLwsbcn+DDktnez0JwKnWZNtslR5PizGvUzIsjb+2S0ymrRwtgBN2N8NzFiZgUJHzPkesyv+Eoh4eKqsRHLz9CScpV+oN9sR9C/WF5qgY0lI6yJwYH9oS/ZHpJUqIPaINzrPJsBwPDRhbJ2JUmpZakyTI9X5znOV13cIkdGaFuAvCH8ir/bFJhJWmzuKMRRfOdXQ9qkEdHD1ME0/G+ncQJcDA49Uf7acvNfdaF78KTGakwlkWGJ0qte/TPnntP42xpMss8OHezmWnTjMdO0EKxt8sR3I/Rg1VdfTubTI0jDgwYlqc7DchGg/vbDvngQH39UOI6ON1IBGV3emjr98Lzv+Crphzya3qTk6xWrXpffFp1IU0NxzJLg87U5vVT55y9eHNfuYq5rIUjEOINcT/M3gBiUMhMLthR8l0JZ1lRp4943Lgd+O7/5lWOHbCNrjzEpaPQySzqPLcc7Kox/4eYMBl99rNJ6U5Wm+yNvciovJJTPMdg7ExjGGrNSAbIH/zzKsNWoAmAWo2xOdKKnkCqNuP/s/0qkFx6WNCijLXnoZviN8Kud29EsDQ== jenkins@eatech.al"
  "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC5/JJGPy22t81xyiMC6qmrc7Upcjx1dt+S2EQtwSF3d5o58SGxizybIHhQytsVHRQM6/KcKqHcJk+Txu8ip86W3eL4WNjmkLyrl2qZCGN1GSRl8X8qfYnT84HqxGfU3AbyUM5yvDOORYXYRb9FXx/XVvtZj9pQ9pFJtRPCj4NVSS/6d1DJKR3q7lZWCzA0dYJUOAJBWSLBDwX1uA/7BlcXpnykywKXB1d2cmugffYQ86bJkoYW643ILdVZKLBVL7F1QlpBCRDsf2sbObqPhmsoZb6apQdbFUAc193Njm/XWgk7ix62Mg6hd7lViAlbZCshoK4/kAdjm1vCFnaZq1TZGx8Hwd5st9kLBaNlZ2WqjPVspKwW9VIWnpNIm3kUEICDkYmRhO7RbRPz2nBNBLuebh/n0QibCPsE4XQfnd7fE6+aeR+yD0rkgK5FGcMwlPFvXZ7ftCWV8R8UBrry2oahi72khZj4EV62/7gnLl2ICSaQqH0aeNic0YSr2SB2GqXZCLapdZAJBKsh/O5jk6Y7Cm7V3eEEX86bUKKwHREQj63sBYz7nHeFYCGAcCyrWQpE1FfiJZFKWV/oja52P9ShZ/d2yPUscH3uJjEB9gCbH+6COKkkkJkffiIKsEvlK/zQ+WMQIkJhty9FEoQcK730jDyZEVSWsGmIhpZVhDJEiw== jenkins@mail"
)

deploy_keys_to_jenkins() {
  local remote_user=$1
  echo "Deploying keys to $TARGET_USER on $remote_user"

  JENKINS_HOME=$(ssh "$remote_user" "sudo -u $TARGET_USER -H bash -c 'echo \$HOME'")

  for key in "${PUBLIC_KEYS[@]}"; do
    escaped_key=$(printf '%s\n' "$key" | sed 's/[.[\*^$(){}?+|]/\\&/g')

    ssh "$remote_user" bash -c "'
      sudo -u $TARGET_USER mkdir -p $JENKINS_HOME/.ssh &&
      sudo -u $TARGET_USER chmod 700 $JENKINS_HOME/.ssh &&
      sudo -u $TARGET_USER touch $JENKINS_HOME/.ssh/authorized_keys &&
      sudo -u $TARGET_USER chmod 600 $JENKINS_HOME/.ssh/authorized_keys &&
      if ! sudo -u $TARGET_USER grep -Fxq \"$key\" $JENKINS_HOME/.ssh/authorized_keys; then
        echo \"$key\" | sudo -u $TARGET_USER tee -a $JENKINS_HOME/.ssh/authorized_keys > /dev/null
      else
        echo \"Key already present, skipping.\"
      fi
    '"
  done

  if [ $? -eq 0 ]; then
    echo "✅ Keys deployed to $TARGET_USER on $remote_user"
  else
    echo "❌ Failed to deploy keys to $TARGET_USER on $remote_user"
  fi
}

for remote_user in "${REMOTE_USERS[@]}"; do
  deploy_keys_to_jenkins "$remote_user"
done
