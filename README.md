## Waybar alarm clock
This module:
- is minimal and beginner-friendly
- uses only two bash scripts
- shows how to add custom output to [Waybar](https://github.com/Alexays/Waybar)

>Information about Waybar and custom modules 
>- [Waybar Wiki](https://github.com/Alexays/Waybar/wiki)
>- [custom module](https://github.com/Alexays/Waybar/wiki/Module:-Custom)
>- [custom module examples](https://github.com/Alexays/Waybar/wiki/Module:-Custom:-Examples)

## About the module
Dependencies to run this module with Waybar:
- [wofi](https://github.com/SimplyCEO/wofi) for entering the alarm time
- Bash
- ```date``` (GNU coreutils)

### Installation
- clone or copy the scripts into:
```~/.config/waybar-alarm/```
- make them executable:
```chmod +x alarm.sh set_alarm.sh```
- add the module to your Waybar ```config.jsonc``` (see [styling below](https://github.com/0x2aAs/waybar-alarm-clock#styling)):
```
"custom/alarm": {
    "exec": "~/.config/waybar-alarm/alarm.sh",
    "on-click": "~/.config/waybar-alarm/set_alarm.sh",
    "return-type": "json",
    "interval": 1
}
```
4. Reload Waybar ```killall -SIGUSR2 waybar```

### How to use the module
Create an alarm:
- left-click opens a wofi window
- enter a specific time ```16:30``` or time interval ```30 minutes```
- or a full date with time ```2042-03-14 7:00```

Delete a running alarm:
- clicking the alarm deletes it


The module scripts use internally the ```date``` command
- date and times are always specified from least to most precise: YEAR-MONTH-DAY hour-minute-second
- see also the [man page for date](https://man7.org/linux/man-pages/man1/date.1.html#DATE_STRING):
> The ```--date=STRING``` is a mostly free format human readable date string such as "Sun, 29 Feb 2004 16:21:42 -0800" or "2004-02-29
     16:21:42" or even "next Thursday". 

### How it works
Since Waybar modules are just commands that output JSON or text, you can hook anything you want into it via scripts. You do not have to write a native C++ module.
The alarm-clock script itself does not run in a loop, instead
- Waybar executes ```alarm.sh``` every ```interval``` seconds
- The script must print exactly one JSON object to ```stdout```
- Waybar reads that JSON and updates the module

### State handling
To remember the alarm time, the script stores a Unix timestamp in a file:
```~/.config/waybar-alarm/state```

Unix timestamps 
- count the seconds since the epoch, e.g. ```1710427200```
- are timezone independent
- allow simple numeric comparison and calculations

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
- converts input into a Unix timestamp
- writes it into the state file
- if an alarm is already active, clicking it deletes the file with ```rm $state_file```

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
You can also make the module background blink red for better visibility of a triggered alarm:
```
#custom-alarm.active {
    background-color: red;
    animation-name: blink;
    animation-duration: 0.3s;
    animation-timing-function: steps(12);
    animation-iteration-count: infinite;
    animation-direction: alternate;
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
