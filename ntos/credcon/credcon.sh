#!/bin/bash

export DISPLAY=:0

currentUser=$(whoami)
rdpFile="/home/${currentUser}/Templates/remote-connection.rdp"

show_loading_bar() {
    echo 'Starting loading bar'

    # Start the loading bar in the background and get its PID
    for ((i=1; i<=100; i++)); do
        echo $i
        echo "# $i%" > /dev/tty
        sleep 0.1
    done | yad --progress \
        --title='Loading' \
        --text='Connecting' \
        --width=400 \
        --height=200 \
        --button='Cancel' \
        --auto-kill \
        --auto-close
}

# Show credential input dialog
show_credential_dialogue() {
    credentials=$(yad --form \
                  --title='Login' \
                  --text='Enter your credentials' \
                  --field='Email:' \
                  --field='Password:':H \
                  --button='Submit':0 \
                  --button='Cancel':1 \
                  --width=400 \
                  --height=200 \
                  --separator=',')

    result=$?
}

# Show dialogue with 'Connection failed'
show_connection_failure() {
    yad --form \
        --title='Connection Closed' \
        --text='Connection was Terminated.' \
        --button='Ok':0 \
        --width=400 \
        --height=200
}

main() {
    show_credential_dialogue

    if [ "$result" -eq 0 ]; then
        # Extract username and password from credentials
        username=$(echo "$credentials" | awk -F',' '{print $1}')
        password=$(echo "$credentials" | awk -F',' '{print $2}')

        show_loading_bar &

        # Start xfreerdp session in the background and get its process ID (PID)
        xfreerdp "$rdpFile" /u:"${username}" /p:"${password}" /cert-ignore &>> /dev/null &
        xfreerdp_pid=$!

        # Wait for the xfreerdp process up to 30 seconds
        threshold=30
        elapsed=0
        interval=1

        while kill -0 "$xfreerdp_pid" 2> /dev/null; do
            sleep "$interval"
            elapsed=$(($elapsed + $interval))

            # If xfreerdp has been running for more than 30 seconds, exit the loop
            if [ "$elapsed" -ge "$threshold" ]; then
                echo 'xfreerdp ran for more than 30 seconds Assuming success..'
                disown "$xfreerdp_pid"
                pkill -f yad
                exit 0
            fi
        done

        # If we exit the loop in under 30 seconds, it means xfreerdp terminated early
        echo "xfreerdp terminated early (less than '${threshold}' seconds)."
        pkill -f yad
        show_connection_failure
        exit 0
    fi
}

# Call main function
main
