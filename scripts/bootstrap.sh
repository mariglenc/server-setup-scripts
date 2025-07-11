#!/bin/bash

SCRIPT_BASE_URL="https://raw.githubusercontent.com/mariglenc/server-setup-scripts/main/scripts"

run_script() {
    local script_name=$1
    echo "--- Running $script_name ---"
    wget -q "$SCRIPT_BASE_URL/$script_name" -O "/tmp/$script_name"
    chmod +x "/tmp/$script_name"
    /tmp/$script_name
    if [ $? -ne 0 ]; then
        echo "Error running $script_name. Aborting."
        exit 1
    fi
    echo "--- Finished $script_name ---"
    echo ""
}

run_script "0.add-host-name.sh"
run_script "1.add-remote-hosts.sh"
run_script "2.add-sysmon.sh" 
run_script "3.add-users.sh"
run_script "5.add-applications.sh"
run_script "6.grant-remote-to-applications.sh"

echo "All initial configuration scripts executed."