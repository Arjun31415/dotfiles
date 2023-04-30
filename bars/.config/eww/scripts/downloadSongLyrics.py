import argparse
import os
import spotipy
import json
from spotipy.oauth2 import SpotifyClientCredentials
from dotenv import load_dotenv
import requests

load_dotenv()  # take environment variables from .env.

USER_AGENT = "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/101.0.4951.41 Safari/537.36"
TOKEN_URL = (
    "https://open.spotify.com/get_access_token?reason=transport&productType=web_player"
)


class Spotify:
    def __init__(self, sp_dc_token):
        self.spotify = spotipy.Spotify(
            client_credentials_manager=SpotifyClientCredentials()
        )
        self.session = requests.Session()
        self.session.cookies.set("sp_dc", sp_dc_token)
        self.session.headers["User-Agent"] = USER_AGENT
        self.session.headers["app-platform"] = "WebPlayer"
        self.login()

    def login(self):
        try:
            req = self.session.get(TOKEN_URL, allow_redirects=False)
            token = req.json()
            self.token = token["accessToken"]
            self.session.headers["authorization"] = f"Bearer {self.token}"
        except Exception as e:
            raise Exception("sp_dc provided is invalid, please check it again!") from e

    def getTrackId(self, trackTitle, artist, otherQueryString):
        if artist is None:
            queryString = f"track:{trackTitle} {otherQueryString}"
        else:
            queryString = f"track:{trackTitle} artist:{artist} {otherQueryString}"
        result = self.spotify.search(queryString, type="track", limit=1)
        if result is None:
            raise Exception("error getting track results query: " + queryString)
        return result["tracks"]["items"][0]["id"]

    def getLyrics(self, trackId: str):
        params = "format=json&market=from_token"
        req = self.session.get(
            f"https://spclient.wg.spotify.com/color-lyrics/v2/track/{trackId}",
            params=params,
        )
        # print(req.status_code)
        return req.json()["lyrics"]["lines"] if req.status_code == 200 else None

    def getLyricsMap(self, trackId: str):
        lyrics = self.getLyrics(trackId)
        if lyrics is None:
            return None
        lyricsMap = {}
        for entry in lyrics:
            lyricsMap[int(entry["startTimeMs"])] = entry["words"]
        return lyricsMap


parser = argparse.ArgumentParser()
parser.add_argument("-t", "--trackTitle", help="Title of the track")
parser.add_argument("-a", "--artist", help="Artist of the track")


def parse_args():
    args = parser.parse_args()
    if not args.trackTitle:
        raise Exception("Track title is required")
    return args


def main():
    args = parse_args()
    trackTitle = args.trackTitle
    artist = args.artist
    sp = Spotify(os.environ["SP_DC"])
    trackId = sp.getTrackId(trackTitle, artist, "")
    lyrics = sp.getLyricsMap(trackId)
    print(trackId)
    # print(json.dumps(lyrics, indent=4, sort_keys=True))
    # write to file $HOME/.cache/eww-dashboard/lyrics-{trackID}.json
    # get the $HOME env variable
    HOME = os.environ["HOME"]
    # make directory if it doesn't exist
    os.makedirs(f"{HOME}/.cache/eww-dashboard", exist_ok=True)
    with open(f"{HOME}/.cache/eww-dashboard/lyrics-{trackId}.json", "w") as outfile:
        json.dump(lyrics, outfile)


if __name__ == "__main__":
    main()
