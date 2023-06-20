#!/bin/python3
# Requires requests
import subprocess

import requests
import json
import os
from pathlib import Path

LOCALREPO = Path("~/.local/share/localrepos/multiviewer/x86_64/").expanduser().resolve()

releases = json.loads(requests.get("https://api.multiviewer.dev/api/v1/releases").text)
latest_dl = releases[0]["version"]

if not any(latest_dl in f for f in os.listdir(LOCALREPO)):
    print(f"Downloading MultiViewer for F1(R) {latest_dl}...")
    subprocess.run(
        [
            "wget",
            f"https://releases.multiviewer.app/download/109949043/multiviewer-for-f1-{latest_dl}-1.x86_64.rpm",
            "--directory-prefix",
            LOCALREPO,
        ],
        check=True,
    )
    subprocess.run(["createrepo", LOCALREPO], check=True)
    print("Successfully registered to local repo. Update can be installed via DNF.")
else:
    print(f"No updates to MultiViewer for F1(R). Current release is {latest_dl}.")
