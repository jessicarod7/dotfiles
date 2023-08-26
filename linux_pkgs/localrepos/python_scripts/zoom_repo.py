#!/bin/python3
# Requires requests

from update_repo import update_repo

from pathlib import Path
import re
import sys

import requests


def get_latest_version() -> str:
    resp = requests.get(
        "https://zoom.us/client/latest/zoom_x86_64.rpm", allow_redirects=False
    )

    if (
        resp.status_code == 302
        and (redirect := resp.headers.get("location")) is not None
    ):
        if version_regex := re.search(r"/(\d+(\.\d+?)*)/", redirect):
            version: str = (
                version_regex.group(1) if len(version_regex.groups()) >= 0 else ""
            )

            if version != "":
                return version
            else:
                print(
                    f"Unable to retrieve latest Zoom version. Output of request:\n {resp}\nBody: {resp.text}\nHeaders: {resp.headers}",
                    file=sys.stderr,
                )
                sys.exit(1)


if __name__ == "__main__":
    update_repo(
        "Zoom",
        Path("~/.local/share/localrepos/zoom/x86_64/").expanduser().resolve(),
        get_latest_version,
        lambda v: f"https://zoom.us/client/{v}/zoom_x86_64.rpm",
    )
