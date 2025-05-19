#![cfg_attr(docsrs, feature(doc_auto_cfg))]

use std::path::{Path, PathBuf};
use std::process::{Command, ExitCode};

use clap::Parser;
use jiff::Timestamp;
use jiff::tz::TimeZone;
use reqwest::blocking::{Client, Response};
use reqwest::header::CONTENT_TYPE;
use serde::Deserialize;
use url::Url;
use versions::Versioning;

const MULTIVIEWER_API_URL: &str = "https://api.multiviewer.app/api/v1";

#[derive(Clone, Debug, Parser)]
pub struct Cli {
    /// The platform to download a release for.
    ///
    /// Known platforms and package format: linux (zip), win32 (exe), win32_portable (zip),
    /// darwin_x64 (dmg), darwin_arm64 (dmg), linux_rpm (rpm), linux_deb (deb)
    pub platform: String,

    /// Load into an RPM repo and update it
    #[clap(long)]
    pub repo: bool,

    /// Directory or RPM repo to place the downloaded file into. Repos will also check against
    /// the latest available version before downloading.
    pub path: PathBuf,
}

/// Panics if a package is missing
pub fn check_required_packages() {
    match Command::new("rpm").args(["-V", "rpm"]).status() {
        Ok(s) => {
            if !s.success() {
                panic!("package rpm not installed")
            }
        }
        Err(e) => panic!("package rpm not installed\n{e}"),
    }

    if !Command::new("rpm")
        .args(["-V", "createrepo_c"])
        .status()
        .expect("failed to call rpm command")
        .success()
    {
        panic!("package createrepo_c not installed")
    }
}

/// Get the latest version in the repo
pub fn get_repo_release(repo: &Path) -> Option<Versioning> {
    let repo_cmd = match Command::new("rpm")
        .args([
            "-q",
            "--queryformat",
            "%{VERSION}\\n",
            "-p",
            repo.join("*.rpm").to_str().unwrap(),
        ])
        .output()
    {
        Ok(output) => {
            if output.status.success() {
                output
            } else {
                eprintln!(
                    "skipping current version check - error while querying repo packages ({}):\n{}",
                    output.status,
                    String::from_utf8(output.stderr).unwrap_or_else(|_| String::new())
                );
                return None;
            }
        }
        Err(cmd_err) => {
            eprintln!("skipping current version check - failed to query repo packages:\n{cmd_err}");
            return None;
        }
    };

    let mut repo_releases: Vec<Versioning> = String::from_utf8(repo_cmd.stdout)
        .expect("non UTF-8 output")
        .lines()
        .flat_map(Versioning::new)
        .collect();

    repo_releases.sort_unstable();
    match repo_releases.last() {
        None => {
            eprintln!("skipping current version check - no versions identified");
            None
        }
        r => r.cloned(),
    }
}

/// Returns a download of the latest release. If this matches the result of [`get_repo_release`],
/// the program exits with code 0 and no release is downloaded.
///
/// Panics for draft or prerelease versions.
pub fn get_latest_release(
    client: &Client,
    platform: String,
    current_release: Option<Versioning>,
) -> Result<(Download, Response), ExitCode> {
    let release: Release = match client
        .get(format!("{MULTIVIEWER_API_URL}/releases/latest"))
        .header(CONTENT_TYPE, "application/json")
        .send()
    {
        Ok(resp) => resp.json().expect("failed to parse release data"),
        Err(e) => panic!("unable to retrieve latest release from {MULTIVIEWER_API_URL}:\n{e}"),
    };

    if current_release.is_some_and(|current| current == release.version) {
        println!("latest version is already downloaded, exiting");
        return Err(ExitCode::SUCCESS);
    }
    if release.draft || release.prerelease {
        panic!(
            "draft or prerelease version {} will not be downloaded",
            release.version
        )
    }

    let target = release
        .downloads
        .iter()
        .find(|dl| dl.platform == platform && dl.dl_type == DownloadType::Download)
        .unwrap_or_else(|| {
            panic!(
                "version {} download not available for platform {platform}",
                release.version
            )
        });

    let formatted_release_notes =
        release
            .release_notes
            .lines()
            .fold(String::new(), |mut indent, l| {
                indent.push_str(&format!(">> {l}\n"));
                indent
            });

    println!(
        "Downloading {} (released {})...\n=== Release notes ===\n{}",
        target.name,
        release
            .published_at
            .to_zoned(TimeZone::system())
            .strftime("%F %T %Z"),
        formatted_release_notes
    );
    Ok((
        target.to_owned(),
        client
            .get(target.url.clone())
            .send()
            .expect("failed to download latest release"),
    ))
}

/// Write release to directory, and refresh RPM repo.
pub fn install_release(directory: &Path, target: Download, release: Response, refresh_repo: bool) {
    let install_path = directory.join(&target.name);

    std::fs::write(
        &install_path,
        release
            .bytes()
            .expect("unable to extract downloaded release"),
    )
    .expect("failed to save release to file");
    println!("Successfully installed to {}!", install_path.display());

    if refresh_repo {
        println!("Refreshing RPM repo...");
        if Command::new("createrepo_c")
            .args(["--update", &directory.display().to_string()])
            .status()
            .expect("failed to refresh RPM repo")
            .success()
        {
            println!("Successfully refreshed repo!")
        } else {
            panic!("failed to refresh RPM repo")
        }
    }
}

#[derive(Clone, Debug, Deserialize)]
struct Release {
    #[serde(deserialize_with = "Versioning::deserialize_pretty")]
    version: Versioning,
    downloads: Vec<Download>,
    draft: bool,
    prerelease: bool,
    published_at: Timestamp,
    release_notes: String,
}

#[derive(Clone, Debug, Deserialize)]
pub struct Download {
    #[allow(unused)]
    id: u64,
    name: String,
    #[allow(unused)]
    size: u64,
    #[serde(rename = "type")]
    dl_type: DownloadType,
    url: Url,
    platform: String,
}

#[derive(Copy, Clone, Debug, Eq, PartialEq, Deserialize)]
#[serde(rename_all = "snake_case")]
enum DownloadType {
    Download,
    /// Not supported
    Update,
}
