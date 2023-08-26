#!/bin/python3
# Requires requests, Selenium, and webdriver-manager

from update_repo import update_repo

from typing import Optional
import json
from pathlib import Path

import requests
from selenium.webdriver import Chrome, ChromeOptions
from selenium.webdriver.chrome.service import Service as ChromeService
from selenium.webdriver.common.by import By
from selenium.webdriver.support.wait import WebDriverWait
from webdriver_manager.chrome import ChromeDriverManager


def latest_version() -> str:
    resp = requests.get("https://api.multiviewer.dev/api/v1/releases")
    releases = json.loads(resp.text)
    return releases[0]["version"]


def get_rpm_url(version: str) -> Optional[str]:
    cr_opt = ChromeOptions()
    cr_opt.add_argument("--headless=new")
    dl_page = Chrome(
        options=cr_opt, service=ChromeService(ChromeDriverManager().install())
    )

    dl_page.get("https://multiviewer.app/download")
    WebDriverWait(dl_page, timeout=15).until(
        lambda d: d.find_element(by=By.PARTIAL_LINK_TEXT, value=version)
    )

    anchor = dl_page.find_element(by=By.XPATH, value='//a[@data-platform="linux_rpm"]')
    rpm_url = anchor.get_attribute("href")
    dl_page.quit()

    try:
        return rpm_url if version in rpm_url else None
    except TypeError:
        return None


if __name__ == "__main__":
    update_repo(
        "MultiViewer for F1(R)",
        Path("~/.local/share/localrepos/multiviewer/x86_64/").expanduser().resolve(),
        latest_version,
        get_rpm_url,
    )
