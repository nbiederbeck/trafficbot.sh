#!/bin/bash
TOKEN=$TOKEN
CHAT_ID=$CHAT_ID
URL="https://api.telegram.org/bot$TOKEN"
SENDURL="$URL/sendMessage"
GETURL="$URL/getUpdates"

function post_message {
    curl -s -X POST $SENDURL -d chat_id=$CHAT_ID -d text="$1" > /dev/null
}

function get_last_message_info {
    MESSAGE=$(curl -s -X GET $GETURL | tail -1)
    DATE=$(echo $MESSAGE | grep -o -E 'date":[0-9]*' | grep -o -E '[0-9]*')
    TEXT=$(echo $MESSAGE | awk '/traffic/ {print "traffic"}; !/traffic/ {print "ERROR"}')
}

function get_traffic {
    TRAFFIC=$(curl -s gateway.engel/traffic.php | awk '/bleiben noch/ {print $42" MB"}')
}

OLDDATE=0
while [[ 1 ]]; do
    get_last_message_info
    if [[ $DATE > $OLDDATE ]]; then
        OLDDATE=$DATE
        case $TEXT in
            traffic)
                get_traffic
                post_message "$TRAFFIC" ;;
            ERROR)
                post_message "There were errors in your request." ;;
        esac
    else
        sleep 2 # wait n seconds before checking again, therefore have answer delay of n seconds
    fi
done
