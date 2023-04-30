from sortedcontainers import SortedDict
import sys
import os
import json
import argparse

HOME = os.environ["HOME"]


def eprint(*args, **kwargs):
    print(*args, file=sys.stderr, **kwargs)


lyrics = SortedDict({})
parser = argparse.ArgumentParser()
parser.add_argument(
    "-i", "--trackId", help="trackId of the song for which lyrics need to be got"
)


def parse_args():
    args = parser.parse_args()
    if not args.trackId:
        parser.error("No trackId provided. Please provide a trackId")
    return args


def watch_input(fname):
    lyricTime = 0
    while True:
        lyricTime = 0
        with open(fname) as fifo:
            for data in fifo:
                lyricTime = data
            # eprint(lyricTime)
            try:
                # lyrics_out = open(HOME + "/.config/eww/scripts/lyricsOutput.fifo", "w")
                lyricTime = float(lyricTime) * 1000
                lyricTime = int(lyricTime)
                if lyricTime == -1:
                    break
                lowerBound = lyrics.irange(-lyricTime)
                lowerBound = next(lowerBound)
                # eprint(lowerBound)
                print("" if lowerBound == 0 else lyrics[lowerBound], flush=True)
                # lyrics_out.write("" if lowerBound == 0 else lyrics[lowerBound])
                # lyrics_out.flush()
                # lyrics_out.close()
                eprint(lyrics[lowerBound])
            except (EOFError, ValueError, StopIteration) as e:
                eprint(e)
            if lyricTime == -1:
                break


def main():
    args = parse_args()
    global lyrics

    with open(HOME + f"/.cache/eww-dashboard/lyrics-{args.trackId}.json") as f:
        lyrics_raw = json.load(f)
    lyrics = SortedDict({-int(k): v for k, v in lyrics_raw.items()})
    watch_input(HOME + "/.config/eww/scripts/lyricsInput.fifo")
    # print(json.dumps(lyrics, indent=4))
    # observe the stdin file for input


if __name__ == "__main__":
    main()
