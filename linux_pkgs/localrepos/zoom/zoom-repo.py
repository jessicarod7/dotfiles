#!/bin/python3
# Requires requests
import subprocess

import requests
import os
from pathlib import Path
import re
import sys

LOCALREPO = Path("~/.local/share/localrepos/zoom/x86_64/").expanduser().resolve()

resp = requests.get("https://zoom.us/client/latest/zoom_x86_64.rpm", allow_redirects=False)
latest_dl: str = ""
if resp.status_code == 302 and (redirect := resp.headers.get('location')) is not None:
    vers = re.search(r'/(\d+(\.\d+?)*)/', redirect)
    if vers is not None:
        latest_dl = vers.group(1) if len(vers.groups()) >= 0 else ""
if latest_dl == "":
    print(f"Unable to retrieve latest Zoom version. Output of request:\n {resp}\nBody: {resp.text}\nHeaders: {resp.headers}", file=sys.stderr)
    sys.exit(1)

if not any(latest_dl in f for f in os.listdir(LOCALREPO)):
    print(f"Downloading Zoom {latest_dl}...")
    subprocess.run(
        [
            "wget",
            f"https://zoom.us/client/{latest_dl}/zoom_x86_64.rpm",
            "--directory-prefix",
            LOCALREPO,
        ],
        check=True,
    )
    subprocess.run(["createrepo", LOCALREPO], check=True)
    print("Successfully registered to local repo. Update can be installed via DNF.")
else:
    print(f"No updates to Zoom. Current release is {latest_dl}.")
