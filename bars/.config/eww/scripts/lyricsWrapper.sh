echoerr() { printf "%s\n" "$*" >&2; }
rm "$HOME"/.config/eww/scripts/lyrics.txt
artist=$(playerctl metadata --format '{{ artist }}')
title=$(playerctl metadata --format '{{ title }}')
track_id=$(~/.config/eww/scripts/.venv/bin/python ~/.config/eww/scripts/downloadSongLyrics.py --trackTitle \""$title"\" --artist \""$artist"\")
# "$HOME"/.config/eww/scripts/.venv/bin/python "$HOME"/.config/eww/scripts/getSongLyrics.py -i "$track_id" >> "$HOME"/.config/eww/scripts/lyricsOutput.fifo
"$HOME"/.config/eww/scripts/.venv/bin/python "$HOME"/.config/eww/scripts/getSongLyrics.py -i "$track_id"
