#!/usr/bin/env bash

STATE_FILE="${HOME}/.config/waybar-alarm/state"

# If an alarm is set, clicking again deletes it
if [[ -f "$STATE_FILE" ]]; then
    rm "$STATE_FILE"
    exit 0
else
    INPUT_ALARM=$(echo "" | wofi --dmenu --prompt "Set alarm (HH:MM:SS)")

    # If the user closes the wofi window without submitting a value
    if [[ -z "$INPUT_ALARM" ]]; then 
        exit 0
    fi

    TIME_ALARM="$(date -d "$INPUT_ALARM" +%s)"
    TIME_NOW="$(date +%s)"

    # If it's e.g. 8 pm and you enter 7:00 for the next morning
    if ((TIME_ALARM < TIME_NOW)); then 
        TIME_ALARM="$(date -d "tomorrow $INPUT_ALARM" +%s)"
    fi

    echo "$TIME_ALARM" > "$STATE_FILE"
    exit 0
fi 
