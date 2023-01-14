#!/bin/bash

appname=$(echo "$1" | sed '/^$/d')
summary=$(echo "$2" | sed '/^$/d' | xargs)
body=$(echo "$3" | sed '/^$/d' | xargs)
icon=$(echo "$4" | sed '/^$/d')
urgency=$(echo "$5" | sed '/^$/d')
# echo $icon
timestamp=$(date +"%I:%M %p")
if [[ "$appname" == "Spotify" ]]; then
    random_name=$(mktemp --suffix ".png")
    artlink=$(playerctl metadata mpris:artUrl | sed -e 's/open.spotify.com/i.scdn.co/g')
    curl -s "$artlink" -o "$random_name"
    icon=$random_name
elif [[ "$appname" == "VLC media player" ]]; then
    icon="vlc"
# elif [[ "$appname" == "Calendar" ]] || [[ "$appname" == "Volume" ]] || [[ "$appname" == "Brightness" ]] || [[ "$appname" == "notify-send" ]]; then
#     exit 0
fi

echo -en "$timestamp\n$urgency\n$icon\n$body\n$summary\n$appname\n" >>$HOME/.cache/dunst.log
