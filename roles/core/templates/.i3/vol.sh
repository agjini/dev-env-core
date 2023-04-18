#!/bin/sh

VOL_STEPS=5

vol() {
    pamixer --get-volume
}

inc() {
    [[ -n "$1" ]] && VOL_STEPS=$1
    pamixer --unmute --allow-boost --increase $VOL_STEPS
    [[ -z "$2" ]] && notifyVolume
}

dec() {
    [[ -n "$1" ]] && VOL_STEPS=$1
    pamixer --unmute --allow-boost --decrease $VOL_STEPS
    [[ -z "$2" ]] && notifyVolume
}

mute() {
    pamixer -t
    
    local m=$(pamixer --get-mute)
    if [[ "$m" == "true" ]]
    then
        notify-send "Mute" -i "audio-subwoofer" -t 2000 -h string:synchronous:"─"
    else
        notify-send "Unmute" -i "audio-subwoofer-testing" -t 2000 -h string:synchronous:"─"
    fi;
}

notifyVolume() {
    local v=$(pamixer --get-volume)
    [[ "$v" -gt 100 ]] && v=100 # max value
    
    notify-send "Volume $v" -i "audio-subwoofer-testing" -t 2000 -h int:value:"$v" -h string:synchronous:"─"
}

case "$1" in
    up)
        inc "$2" "$3"
        ;;
    down)
        dec "$2" "$3"
        ;;
    toggle)
        mute
        ;;
    n|noti|notify)
        noti
        ;;
    *)
        vol
        ;;
esac