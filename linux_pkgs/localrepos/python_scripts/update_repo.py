#!/bin/python3
# Requires requests
import subprocess

import os
import sys
from pathlib import Path
from collections.abc import Callable
from typing import Optional

INIT_RPM_NAME = "new_package_version.rpm.tmp"


def update_repo(
    name: str,
    localrepo_dir: Path,
    version_fn: Callable[[], str],
    download_url_fn: Callable[[str], Optional[str]],
):
    """
    :param name: Name of the package to update
    :param localrepo_dir: Directory containing the local repo
    :param version_fn: :class:`Callable` returning the version of the latest release, as retrieved from APIs, website,
        etc. Version strings **must** be part of the RPM names in the ``localrepo_dir``
    :param download_url_fn: :class:`Callable` which is provided the current version, and returns a valid URL to download
        the RPM, or :type:`None`
    :raises ValueError: If ``version_fn`` or ``download_url_fn`` does not return a value
    """

    version = version_fn()
    if version is not None:
        download_url = download_url_fn(version)
    else:
        raise ValueError(f"Unable to acquire version string.")

    if download_url is None:
        raise ValueError(f"Unable to acquire download URL. Version used was {version}")

    if not any(version in f for f in os.listdir(localrepo_dir)):
        print(f"Downloading {name} {version}...")
        subprocess.run(
            [
                "wget",
                "-O",
                localrepo_dir.joinpath(INIT_RPM_NAME),
                download_url,
            ],
            check=True,
        )

        rpm_name = (
            subprocess.check_output(
                [
                    "rpm",
                    "-q",
                    "--queryformat",
                    "%{NEVRA}",
                    "-p",
                    localrepo_dir.joinpath(INIT_RPM_NAME),
                ]
            ).decode("ascii")
            + ".rpm"
        )

        subprocess.run(
            [
                "mv",
                localrepo_dir.joinpath(INIT_RPM_NAME),
                localrepo_dir.joinpath(rpm_name),
            ],
            check=True,
        )

        subprocess.run(["createrepo_c", localrepo_dir], check=True)
        print(
            f"Successfully added {rpm_name} to local repo. Update can be installed via DNF."
        )
    else:
        print(f"No updates to {name}. Current release is {version}.")
