#!/usr/bin/env bash

MSG_IDLE="no ⏰"
MSG_ALARM="BEEP BEEP ⏰"
ALARM_DURATION=10

STATE_FILE="${HOME}/.config/waybar-alarm/state"

if [[ -f "$STATE_FILE" ]]; then
    TIME_ALARM=$(cat "$STATE_FILE")
else
    TIME_ALARM=""
fi

if [[ -n "$TIME_ALARM" ]]; then
    TIME_NOW="$(date +%s)"
    TIME_DIFF=$((TIME_ALARM - TIME_NOW))

    if ((TIME_DIFF > 0)); then
        HOUR=$((TIME_DIFF / 3600))
        MIN=$((TIME_DIFF / 60 % 60))
        SEC=$((TIME_DIFF % 60))
        echo "{\"text\":\"⏰ $HOUR h $MIN m $SEC s \",\"class\":\"counting\"}"
        exit 0
    fi
    
    if ((TIME_DIFF <= 0)); then
        echo "{\"text\":\"$MSG_ALARM\",\"class\":\"active\"}"
    fi
    
    if ((TIME_DIFF <= -ALARM_DURATION)); then
        rm "$STATE_FILE"
    fi

    exit 0
fi

echo "{\"text\":\"$MSG_IDLE\",\"class\":\"idle\"}"
