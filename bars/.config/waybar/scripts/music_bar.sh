#!/usr/bin/env bash
mode0_cmd="python $HOME/.config/waybar/scripts/mediaplayer.py"
mode1_cmd="$HOME/.config/waybar/scripts/waybar-cava.sh"
CURRENT_MODE=2
child_pid=""
check_mode() {
    WAYBAR_MUSIC_COMP_MODE=$(cat /tmp/waybar_music_mode)
    if [[ $WAYBAR_MUSIC_COMP_MODE == 1 ]]; then
        # echo "visualixer mode"
        return 1
    else
        # echo "info mode"
        return 0
    fi
}
run_mode() {

    mode=$1
    if [[ $mode == "$CURRENT_MODE" ]]; then
        # the current mode is running, just return
        return 0
    elif [[ $mode == 0 ]]; then
        kill $child_pid
        CURRENT_MODE=0
        exec $mode0_cmd &
        child_pid=$!
    else
        kill $child_pid
        CURRENT_MODE=1
        exec $mode1_cmd &
        child_pid=$!
    fi

}
while true; do
    check_mode
    x=$?
    run_mode $x
    sleep 2
done
