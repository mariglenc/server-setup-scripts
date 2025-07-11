cat << 'EOL' > /root/sysmon
#!/bin/bash

printf "%-10s%-15s%-15s%-15s%s\n" "PID" "OWNER" "MEMORY (KB)" "MEMORY (GB)" "COMMAND"

function sysmon_main(){
    RAWIN=$(ps -o pid,user,%mem,command ax | grep -v PID | sort -bnr -k3 | awk '/[0-9]*/{print $1 ":" $2 ":" $4}')

    for i in $RAWIN
    do
        PID=$(echo $i | cut -d: -f1)
        OWNER=$(echo $i | cut -d: -f2)
        COMMAND=$(echo $i | cut -d: -f3)
        MEMORY_KB=$(pmap $PID | tail -n 1 | awk '/[0-9]K/{print $2}')
        MEMORY_GB=$(awk "BEGIN {printf \"%.2f\", ${MEMORY_KB%K} / 1024 / 1024}")
        
        printf "%-10s%-15s%-15s%-15s%s\n" "$PID" "$OWNER" "$MEMORY_KB" "$MEMORY_GB" "$COMMAND"
    done
}


sysmon_main | sort -bnr -k3
EOL

chmod +x sysmon