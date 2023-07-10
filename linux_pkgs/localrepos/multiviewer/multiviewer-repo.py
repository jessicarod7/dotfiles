#!/bin/python3
# Requires requests

import json
import os
import subprocess
import sys
from pathlib import Path

from bs4 import BeautifulSoup, Tag
import requests

LOCALREPO = Path("~/.local/share/localrepos/multiviewer/x86_64/").expanduser().resolve()


def get_rpm_url(version: str) -> str | None:
    rpm_url: str = ""

    dl_page = BeautifulSoup(requests.get("https://multiviewer.app/download").text, 'html.parser')
    for anchor in dl_page.find_all("a"):
        if isinstance(anchor, Tag):
            if any('linux_rpm' in attribute for attribute in list(anchor.attrs.values())):
                rpm_url = anchor.get("href")

    return rpm_url if version in rpm_url else None


releases = json.loads(requests.get("https://api.multiviewer.dev/api/v1/releases").text)
latest_dl = releases[0]["version"]

if not any(latest_dl in f for f in os.listdir(LOCALREPO)):
    print(f"Downloading MultiViewer for F1(R) {latest_dl}...")

    rpm_url = get_rpm_url(latest_dl)

    if rpm_url is not None:
        subprocess.run(
            [
                "wget",
                rpm_url,
                "--directory-prefix",
                LOCALREPO,
            ],
            check=True,
        )
        subprocess.run(["createrepo_c", LOCALREPO], check=True)
        print("Successfully registered to local repo. Update can be installed via DNF.")
    else:
        print(f"Unable to retrieve RPM for {latest_dl} from multiviewer.app/download -- repo not updated")
        sys.exit(1)
else:
    print(f"No updates to MultiViewer for F1(R). Current release is {latest_dl}.")
