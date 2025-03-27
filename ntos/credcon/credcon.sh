#!/bin/bash

# Some environmnet variables.
rdpFile="/opt/ntos/remote-connection.rdp"
yad_lock=0

# A YAD loading bar to create the illusion that the system is doing something (which it is).
# The reason is that a non-technical person might not understand the fact that the system is doing something in the background.
show_loading_bar() {
    echo 'Starting loading bar'

    for ((i=1; i<=100; i++)); do
        echo $i | tee /dev/null
        echo "# $i%" | tee /dev/tty
        sleep 0.1
    done | yad --progress \
        --title='Credcon Utility' \
        --text="\nLoading...\nPlease stand by.\n\n" \
        --width=400 \
        --height=225 \
        --no-buttons \
        --auto-kill \
        --auto-close \
        --center \
        --text-align=center

    # QoL Feature where it pops up with a slow connection.
    local freerdp_open=0
    for window in $(xprop -root | grep '_NET_CLIENT_LIST_STACKING(WINDOW)' | grep -oE '0x[0-9a-f]+'); do
        if xprop -id "$window" | grep -q "xfreerdp"; then
            echo "The xfreerdp3 window has popped up."

            freerdp_open=1
            break
        else
            echo "$window" "is not xfreerdp"

            freerdp_open=0
        fi
    done

    if [[ $freerdp_open -eq 0 ]] && [[ yad_lock -ne 1 ]]; then
        yad --title='Credcon Utility' \
            --text="\nSlow connection detected... Please wait.\n(The connection will start any second)" \
            --no-buttons \
            --width=400 \
            --height=225 \
            --auto-kill \
            --center \
            --text-align=center
    fi
}

# Show credential input dialog this is to get the credentials for the RDP-session.
# Simple yet powerful, while not taking over the entire monitor.
show_credential_dialogue() {
    credentials=$(yad --form \
                  --title='Credcon Utility' \
                  --text='Enter your credentials\n' \
                  --field='Email/User:' \
                  --field='Password:':H \
                  --button='Submit':0 \
                  --button='Cancel':1 \
                  --width=400 \
                  --height=225 \
                  --separator=',')

    result=$?
}

# Show dialogue with 'Connection failed', this is done to notice the user that something might not have gone completely right.
# The purpose for this is to display this once a connection failed, not when it succeeded.
show_connection_failure() {
    yad --form \
        --title='Credcon Utility' \
        --text='\nConnection was Terminated early...\n\n' \
        --button='Okay':0 \
        --width=400 \
        --height=225
}

# Main loop, because I am a bit used to that programming structure.
main() {
    show_credential_dialogue

    # Check if the input fields from the credential prompt are populated.
    if [ "$result" -eq 0 ]; then

        # Extract username and password from credentials (prompt).
        username=$(echo "$credentials" | awk -F',' '{print $1}')
        password=$(echo "$credentials" | awk -F',' '{print $2}')

        # Show the loading bar in the background, this is made because the FreeRDP session will take over the entire screen.
        show_loading_bar &

        # Start xfreerdp session in the background and get its process ID (PID).
        # This does not hinder the process from taking over the (screen/monitor) session.
        # Format 0 is because of the ffmpeg bug: https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=1098488 https://github.com/FreeRDP/FreeRDP/pull/11225
        xfreerdp3 "$rdpFile" /u:"${username}" /p:"${password}" \
            /drive:hotplug,* /sound /microphone:format:1 /printer \
            /auth-pkg-list:!kerberos \
            +auto-reconnect /auto-reconnect-max-retries:50 \
            /cert:ignore &
        # To enable floating bar (sticky) add: /floatbar:sticky:off,default:visible,show:fullscreen
        xfreerdp_pid=$!

        # Wait for the xfreerdp process up to $interval seconds, default 30.
        threshold=30
        elapsed=0
        interval=1

        # Keep track of how long the FreeRDP process is alive for.
        while kill -0 "$xfreerdp_pid" 2> /dev/null; do
            sleep "${interval}s"
            elapsed=$((elapsed + interval))

            # If xfreerdp has been running for more than 30 seconds, exit the loop (connection likely succeeded).
            if [ "$elapsed" -ge "$threshold" ]; then
                echo 'xfreerdp ran for more than 30 seconds Assuming success..'

                # Disown the FreeRDP process to make the script exit gracefully.
                disown "$xfreerdp_pid"

                # Kill all remaining YAD dialogues at threshold.
                pkill -f yad

                # Gracefully exit.
                exit 0
            fi
        done

        # If we exit the loop in under 30 seconds, it means xfreerdp terminated early, which likely means a failure to login/connect.
        echo "xfreerdp terminated early (less than '${threshold}' seconds)."

        yad_lock=1
        # This is done to kill the loading bar process, because it will be followed-up by the "login_failed" dialogue.
        pkill -f yad

        # Show yad dialogue that displays the connection failure.
        show_connection_failure

        # Kill the bash process, this stops the background counting of the loading bar. While exiting gracefully!
        pkill -f bash &

        # Gracefully exit.
        exit 0
    fi
}

# Call main function
main
