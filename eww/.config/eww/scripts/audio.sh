#!/usr/bin/env bash

case "$1" in
"symbol")
    pactl subscribe | grep --line-buffered "Event 'change' on client" | while read -r; do
        case "$(pactl get-default-sink)" in
        *Arctis_9*) echo "" ;;
        #*Arctis_9*) echo "";;
        *) echo "" ;;
        esac
    done
    ;;
"volume")
    # volume=$(pamixer --get-volume)
    volume=$(amixer sget Master | grep 'Left:' | awk -F'[][]' '{ print $2 }' | tr -d '%')
    echo $volume
    pactl subscribe |
        grep --line-buffered "Event 'change' on sink " |
        while read -r evt; do
            volume=$(pamixer --get-volume | cut -d " " -f1)

            echo $volume
        done
    ;;
"toggle")
    speaker_sink_id=$(pamixer --list-sinks | grep "Komplete_Audio_6" | awk '{print $1}')
    game_sink_id=$(pamixer --list-sinks | grep "stereo-game" | awk '{print $1}')
    case "$(pactl get-default-sink)" in
    *Arctis_9*)
        eww -c ~/.config/eww/eww.yuck update audio_sink=""
        pactl set-default-sink $speaker_sink_id
        ;;
    *)
        eww -c ~/.config/eww/eww.yuck update audio_sink=""
        pactl set-default-sink $game_sink_id
        ;;
    esac
    ;;
esac
