#!/usr/bin/env sh

audio_volume_muted="/usr/share/icons/Tokyonight-Dark/status/symbolic/audio-volume-muted-symbolic.svg"
audio_volume_low="/usr/share/icons/Tokyonight-Dark/status/symbolic/audio-volume-low-symbolic.svg"
audio_volume_medium="/usr/share/icons/Tokyonight-Dark/status/symbolic/audio-volume-medium-symbolic.svg"
audio_volume_high="/usr/share/icons/Tokyonight-Dark/status/symbolic/audio-volume-high-symbolic.svg"

display_brightness_off_symbolic="/usr/share/icons/Tokyonight-Dark/status/symbolic/display-brightness-off-symbolic.svg"
display_brightness_low_symbolic="/usr/share/icons/Tokyonight-Dark/status/symbolic/display-brightness-low-symbolic.svg"
display_brightness_medium_symbolic="/usr/share/icons/Tokyonight-Dark/status/symbolic/display-brightness-medium-symbolic.svg"
display_brightness_high_symbolic="/usr/share/icons/Tokyonight-Dark/status/symbolic/display-brightness-high-symbolic.svg"
notifyMuted() {
    volume="$1"
    dunstify -a volume -h string:x-canonical-private-synchronous:audio "Muted" -h int:value:"$volume" -t 1500 --icon "$audio_volume_muted"

}
is_mute() {
    wpctl get-volume @DEFAULT_AUDIO_SINK@ | cut -d ' ' -f 3
}

get_volume() {
    wpctl get-volume @DEFAULT_AUDIO_SINK@ | cut -d ' ' -f 2
}
get_brightness() {
    brightnessctl get
}
notifyAudio() {
    volume="$1"
    if [ -n "$(is_mute)" ]; then
        notifyMuted "$volume" && return
    fi
    if [ "$volume" -eq 0 ]; then
        notifyMuted "$volume" && return
    elif [ "$volume" -le 30 ]; then
        dunstify -a volume -h string:x-canonical-private-synchronous:audio "Volume: $volume" -h int:value:"$volume" -t 1500 --icon $audio_volume_low
    elif [ "$volume" -le 70 ]; then
        dunstify -a volume -h string:x-canonical-private-synchronous:audio "Volume: $volume" -h int:value:"$volume" -t 1500 --icon $audio_volume_medium
    else
        dunstify -a volume -h string:x-canonical-private-synchronous:audio "Volume: $volume" -h int:value:"$volume" -t 1500 --icon $audio_volume_high

    fi

}

notifyBrightness() {
    brightness="$1"
    if [ "$brightness" -eq 0 ]; then
        dunstify -a brightness -h string:x-canonical-private-synchronous:brightness "Brightness: " -h int:value:"$brightness" -t 1500 --icon $display_brightness_off_symbolic
    elif [ "$brightness" -le 30 ]; then
        dunstify -a brightness -h string:x-canonical-private-synchronous:brightness "Brightness: " -h int:value:"$brightness" -t 1500 --icon $display_brightness_low_symbolic
    elif [ "$brightness" -le 70 ]; then
        dunstify -a brightness -h string:x-canonical-private-synchronous:brightness "Brightness: " -h int:value:"$brightness" -t 1500 --icon $display_brightness_medium_symbolic
    else
        dunstify -a brightness -h string:x-canonical-private-synchronous:brightness "Brightness: " -h int:value:"$brightness" -t 1500 --icon $display_brightness_high_symbolic
    fi

}
case "$1" in
audio)
    case "$2" in
    up)
        wpctl set-mute @DEFAULT_AUDIO_SINK@ 0 && wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+
        ;;
    down)
        wpctl set-mute @DEFAULT_AUDIO_SINK@ 0 && wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-
        ;;
    toggle)
        wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
        ;;

    *) echo "Second argument invalid, must be 'up' or 'down' or 'toggle' " ;;
    esac
    volume=$(get_volume)
    volume=$(echo print "$volume * 100" | perl)
    notifyAudio "$volume"
    ;;
brightness)
    b=$(get_brightness)
    b=$(echo "use integer; print (($b * 100)/255)" | perl)
    notifyBrightness "$b"
    ;;

*)
    echo "Not the right arguments"
    echo "$1"
    exit 2
    ;;
esac
