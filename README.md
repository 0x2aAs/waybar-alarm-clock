## Waybar Alarm – A minimal custom module
This project is intentionally minimal and easy to read.
It is meant as a starting point for learning how custom [Waybar](https://github.com/Alexays/Waybar) modules work, not something that is production-ready.
It's not using background demons, loops or any advanced IPC.

Dependencies:
- Bash
- ```wofi``` for entering the alarm time
- ```date``` (GNU coreutils)

### Installation
1. Clone or copy the scripts into:
```~/.config/waybar-alarm/```

2. Make them executable:
```chmod +x alarm.sh set_alarm.sh```

3. Add the module to your Waybar ```config.jsonc```:
```
"custom/alarm": {
    "exec": "~/.config/waybar-alarm/alarm.sh",
    "on-click": "~/.config/waybar-alarm/set_alarm.sh",
    "return-type": "json",
    "interval": 1
}
```
4. Restart Waybar.

### Setting an alarm
Clicking on the alarm-clock module in Waybar opens a window (```wofi```) that reads the time you want to set the alarm for.
It uses the ```date``` command, therefore an alarm can be entered like this:
- ```30 minutes```
- ```16:30```
- ```2042-03-14 7:00```

If an alarm is set clicking again deletes it.

### How it works
Since Waybar modules are just commands that output JSON or text, you can hook anything you want into it via scripts. You do not have to write a native C++ module.
The alarm-clock script itself does not run in a loop, instead
- Waybar executes ```alarm.sh``` every ```interval``` seconds
- The script must print exactly one JSON object to ```stdout```
- Waybar reads that JSON and updates the module

### State handling
To remember the alarm time, the script stores a Unix timestamp in a file:
```~/.config/waybar-alarm/state```

A Unix timestamp counts the seconds since the epoch and looks like this:
```1710427200```
Timestamps are timezone independent and we can do simple numeric comparison and easy calculations.

### Countdown logic
Core idea inside ```alarm.sh```:
```
TIME_NOW=$(date +%s)
TIME_DIFF=$((TIME_ALARM - TIME_NOW))

If:
TIME_DIFF > 0 → countdown running
TIME_DIFF <= 0 → alarm active
```

The remaining time is calculated using integer division:

```
HOUR=$((TIME_DIFF / 3600))
MIN=$((TIME_DIFF / 60 % 60))
SEC=$((TIME_DIFF % 60))
```

### Click handling
When clicking the module:
```
"on-click": "~/.config/waybar-alarm/set_alarm.sh"
```
Waybar simply executes another script: ```set_alarm.sh```,
which: 
- opens a wofi prompt
- Converts input into a Unix timestamp
- Writes it into the state file
- If an alarm is already active, clicking removes it.

### Styling
The script outputs a JSON class field:
```
{"text":"⏰ 0 h 5 m 12 s","class":"counting"}
```
You can style it in your Waybar ```styles.css```:
```
#custom-alarm.counting {
    color: yellow;
}

#custom-alarm.active {
    color: red;
}

#custom-alarm.idle {
    color: gray;
}
```

### Limitations
This example is intentionally simple, limitations are:
- Script runs every second (inefficient)
- No input validation
- Only one alarm supported
- No sound playback or anything else
- No protection against race conditions
- No recurring alarms
- No daemon

What you can do to extend this example:
- Add sound playback
- Add input validation
- Support multiple alarms
- Add snooze functionality
- Use a lock file
- Rewrite as a background daemon in C for example
- Communicate via FIFO or UNIX socket

Or have fun writing your own custom module.
