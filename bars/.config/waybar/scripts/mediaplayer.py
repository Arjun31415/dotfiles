#!/usr/bin/env python3
import argparse
import logging
import sys
import signal
import gi
import json
from mpd import MPDClient
import signal
import sys

gi.require_version("Playerctl", "2.0")
from gi.repository import Playerctl, GLib

PRINT_TO_STDOUT = True
logger = logging.getLogger(__name__)


def write_output(text, player):
    if not PRINT_TO_STDOUT:
        return
    logger.info("Writing output")

    # output = {
    #     "text": text,
    #     "class": "custom-" + player.props.player_name if player else "mpd",
    #     "alt": player.props.player_name if player else "MPD",
    # }

    # sys.stdout.write(json.dumps(output) + "\n")
    sys.stdout.write(text + "\n")
    sys.stdout.flush()


def on_play(player, status, manager):
    logger.info("Received new playback status")
    on_metadata(player, player.props.metadata, manager)


def on_metadata(player, metadata, manager):
    logger.info("Received new metadata")
    track_info = ""

    if (
        player.props.player_name == "spotify"
        and "mpris:trackid" in metadata.keys()
        and ":ad:" in player.props.metadata["mpris:trackid"]
    ):
        track_info = "AD PLAYING"
    elif player.get_artist() != "" and player.get_title() != "":
        track_info = "{artist} - {title}".format(
            artist=player.get_artist(), title=player.get_title()
        )
    else:
        track_info = player.get_title()

    if player.props.status != "Playing" and track_info:
        track_info = " " + track_info
    write_output(track_info, player)


def on_player_appeared(manager, player, selected_player=None):
    if player is not None and (
        selected_player is None or player.name == selected_player
    ):
        init_playerctl_player(manager, player)
    else:
        logger.debug("New player appeared, but it's not the selected player, skipping")


def on_player_vanished(manager, player):
    logger.info("Player has vanished")
    sys.stdout.write("\n")
    sys.stdout.flush()


def init_playerctl_player(manager, name):
    logger.debug("Initialize player: {player}".format(player=name.name))
    player = Playerctl.Player.new_from_name(name)
    player.connect("playback-status", on_play, manager)
    player.connect("metadata", on_metadata, manager)
    manager.manage_player(player)
    on_metadata(player, player.props.metadata, manager)


def init_mpd_player():
    try:
        player: MPDClient = MPDClient()
        player.connect("localhost", 6600)
        return (True, player)
    except:
        return (False, None)


def handle_mpd(player: MPDClient):
    track_info = ""
    logger.info("Handling MPD")

    while player.idle():
        songInfo = player.currentsong()
        track_info = "{artist} - {title}".format(
            artist=songInfo["artist"], title=songInfo["title"]
        )
        state = player.status()["state"]
        if state != "play" and track_info:
            track_info = " " + track_info
        write_output(track_info, None)


def signal_handler(sig, frame):
    logger.debug("Received signal to stop, exiting")
    sys.stdout.write("\n")
    sys.stdout.flush()
    # loop.quit()
    sys.exit(0)


def parse_arguments():
    parser = argparse.ArgumentParser()

    # Increase verbosity with every occurrence of -v
    parser.add_argument("-v", "--verbose", action="count", default=0)

    # Define for which player we're listening
    parser.add_argument("--player")
    parser.add_argument("--print-to-stdout", action="store", default=True)

    return parser.parse_args()


def main():
    arguments = parse_arguments()
    if arguments.print_to_stdout != True:
        global PRINT_TO_STDOUT
        PRINT_TO_STDOUT = False
    # Initialize logging
    logging.basicConfig(
        stream=sys.stderr,
        level=logging.DEBUG,
        format="%(name)s %(levelname)s %(message)s",
    )

    # Logging is set by default to WARN and higher.
    # With every occurrence of -v it's lowered by one
    logger.setLevel(max((3 - arguments.verbose) * 10, 0))
    signal.signal(signal.SIGINT, signal_handler)
    signal.signal(signal.SIGTERM, signal_handler)
    signal.signal(signal.SIGPIPE, signal.SIG_DFL)
    signal.signal(signal.SIGUSR1, signal_handler)

    # Log the sent command line arguments
    logger.debug("Arguments received {}".format(vars(arguments)))
    # ok, player = init_mpd_player()
    # if ok and player:
    #     # do mpd stuff
    #     handle_mpd(player)
    #     pass
    manager = Playerctl.PlayerManager()
    loop = GLib.MainLoop()

    manager.connect(
        "name-appeared", lambda *args: on_player_appeared(*args, arguments.player)
    )
    manager.connect("player-vanished", on_player_vanished)

    for player in manager.props.player_names:
        if arguments.player is not None and arguments.player != player.name:
            logger.debug(
                "{player} is not the filtered player, skipping it".format(
                    player=player.name
                )
            )
            continue

        init_playerctl_player(manager, player)

    loop.run()


if __name__ == "__main__":
    main()
