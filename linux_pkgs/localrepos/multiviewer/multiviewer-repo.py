#!/bin/python3
# Requires requests

import json
import os
import subprocess
import sys
from pathlib import Path

import requests
from selenium.webdriver import Chrome, ChromeOptions
from selenium.webdriver.common.by import By
from selenium.webdriver.support.wait import WebDriverWait

LOCALREPO = Path("~/.local/share/localrepos/multiviewer/x86_64/").expanduser().resolve()


def get_rpm_url(version: str) -> str | None:
    cr_opt = ChromeOptions()
    cr_opt.add_argument("--headless=new")
    dl_page = Chrome(options=cr_opt)

    dl_page.get("https://multiviewer.app/download")
    WebDriverWait(dl_page, timeout=15).until(
        lambda d: d.find_element(by=By.PARTIAL_LINK_TEXT, value=version)
    )

    anchor = dl_page.find_element(by=By.XPATH, value='//a[@data-platform="linux_rpm"]')
    rpm_url = anchor.get_attribute("href")
    dl_page.quit()

    return rpm_url if rpm_url is None else (rpm_url if version in rpm_url else None)


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
        print(
            f"Unable to retrieve RPM for {latest_dl} from multiviewer.app/download -- repo not updated"
        )
        sys.exit(1)
else:
    print(f"No updates to MultiViewer for F1(R). Current release is {latest_dl}.")