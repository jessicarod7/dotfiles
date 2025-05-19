use std::ffi::OsStr;
use std::fs::{File, FileType};
use std::io;
use std::io::{BufReader, ErrorKind};
use std::path::{Path, PathBuf};
use std::process::ExitCode;
use std::str::FromStr;

use crate::rpm_xml_schemes::primary::{Package, PrimaryMetadata};
use crate::rpm_xml_schemes::repomd::Repomd;
use clap::Parser;
use multiviewer_repo::Cli;
use reqwest::blocking::Client;
use versions::Versioning;
use walkdir::WalkDir;

mod rpm_xml_schemes;

fn create_test_dir(dir_name: &str) -> PathBuf {
    let test_dir =
        PathBuf::from_str(&format!("{}/{dir_name}", env!("CARGO_TARGET_TMPDIR"))).unwrap();
    std::fs::remove_dir_all(&test_dir)
        .ignore_kind(ErrorKind::NotFound)
        .unwrap();
    std::fs::create_dir(&test_dir)
        .ignore_kind(ErrorKind::AlreadyExists)
        .unwrap();
    test_dir
}

#[test]
fn test_download_rpm() {
    let dl_path = create_test_dir("dl_rpm");
    assert_eq!(run_main_section(&dl_path, false), ExitCode::SUCCESS);

    let _ = verify_rpm_downloaded(&dl_path);
}

#[test]
fn test_new_rpm_repo() {
    let new_repo_path = create_test_dir("newrepo");
    assert_eq!(run_main_section(&new_repo_path, true), ExitCode::SUCCESS);

    let rpms = verify_rpm_downloaded(&new_repo_path);
    assert_eq!(rpms.len(), 1);
    let _ = verify_repo_encoding(&new_repo_path, PackageVersion::Latest);
}

#[test]
fn test_update_existing_rpm_repo() {
    const OLD_RPM_NAME: &str = "multiviewer-for-f1-1.19.3-1.x86_64.rpm";

    // Copy repo into integration test environment
    let existing_repo_path = create_test_dir("existing_repo");
    let resources_existing_repo = PathBuf::from_str(&format!(
        "{}/tests/resources/existing_repo",
        env!("CARGO_MANIFEST_DIR")
    ))
    .unwrap();
    for e in WalkDir::new(&resources_existing_repo).min_depth(1) {
        let entry = e.unwrap();
        if entry
            .file_name()
            .to_str()
            .unwrap()
            .starts_with(OLD_RPM_NAME)
        {
            continue;
        }
        let relative_path = entry.path().strip_prefix(&resources_existing_repo).unwrap();

        if entry.file_type().is_dir() {
            std::fs::create_dir(existing_repo_path.join(relative_path)).unwrap()
        } else if entry.file_type().is_file() {
            let _ = std::fs::copy(entry.path(), existing_repo_path.join(relative_path)).unwrap();
        } else {
            panic!(
                "{} is not a file or directory, abandoning existing RPM test setup",
                entry.path().display()
            );
        }
    }

    // Reassemble the RPM
    let mut rpm_bytes =
        std::fs::read(resources_existing_repo.join(format!("{OLD_RPM_NAME}.part1"))).unwrap();
    rpm_bytes.extend(
        std::fs::read(resources_existing_repo.join(format!("{OLD_RPM_NAME}.part2"))).unwrap(),
    );
    std::fs::write(existing_repo_path.join(OLD_RPM_NAME), rpm_bytes)
        .expect("failed to write RPM file");

    assert_eq!(
        run_main_section(&existing_repo_path, true),
        ExitCode::SUCCESS
    );
    let rpms = verify_rpm_downloaded(&existing_repo_path);
    assert_eq!(rpms.len(), 2);
    assert_eq!(
        rpms.iter()
            .filter(|rpm| rpm
                .file_name()
                .is_some_and(|name| name == OsStr::new("multiviewer-for-f1-1.19.3-1.x86_64.rpm")))
            .count(),
        1
    );
    assert_eq!(
        rpms.iter()
            .filter(|rpm| rpm
                .file_name()
                .is_some_and(|name| name != OsStr::new("multiviewer-for-f1-1.19.3-1.x86_64.rpm")))
            .count(),
        1
    );

    let _ = verify_repo_encoding(
        &existing_repo_path,
        PackageVersion::Version(Versioning::new("1.19.3").unwrap()),
    );
    let _ = verify_repo_encoding(&existing_repo_path, PackageVersion::Latest);
}

fn run_main_section(path: &Path, rpm_repo: bool) -> ExitCode {
    let mut input = vec![
        env!("CARGO_CRATE_NAME"),
        "linux_rpm",
        path.to_str().unwrap(),
    ];
    if rpm_repo {
        input.insert(1, "--repo");
    }

    let args = Cli::parse_from(input);
    let client = Client::new();

    let current_release = args
        .repo
        .then(|| {
            multiviewer_repo::check_required_packages();
            multiviewer_repo::get_repo_release(&args.path)
        })
        .flatten();

    let (target, release) =
        match multiviewer_repo::get_latest_release(&client, args.platform, current_release) {
            Ok(rel) => rel,
            Err(exit) => return exit,
        };

    multiviewer_repo::install_release(&args.path, target, release, args.repo);

    ExitCode::SUCCESS
}

/// Assert that one RPM file was downloaded into the directory, returning the path of the RPM.
fn verify_rpm_downloaded(dir_path: &Path) -> Vec<PathBuf> {
    let dir_children = dir_path
        .read_dir()
        .unwrap()
        .filter_map(|e| {
            let entry = match e {
                Ok(inner) => inner,
                Err(_) => return None,
            };
            if entry.file_type().as_ref().is_ok_and(FileType::is_file) {
                Some(entry)
            } else {
                None
            }
        })
        .collect::<Vec<_>>();

    let mut children = vec![];
    for file in dir_children {
        assert_eq!(file.path().extension(), Some(OsStr::new("rpm")));
        children.push(file.path());
    }

    children
}

/// Verify that a package was successfully installed into a repo, returning the [`Package`]
fn verify_repo_encoding(dir_path: &Path, version: PackageVersion) -> Package {
    // Get path to primary list file
    let repomd_reader = BufReader::new(
        File::open(dir_path.join("repodata/repomd.xml")).expect("failed to load repomd.xml"),
    );
    let repomd: Repomd =
        quick_xml::de::from_reader(repomd_reader).expect("failed to deserialize repomd.xml");

    // Load primary list
    let primary_data = repomd
        .data
        .iter()
        .find(|data| data.data_type == "primary")
        .expect("failed to locate \"primary\" entry in repomd.xml");
    let primary_path = dir_path.join(&primary_data.location.href);
    assert_eq!(
        &sha256::try_digest(&primary_path).expect("failed to digest primary list"),
        primary_data
            .checksum
            .text
            .as_ref()
            .expect("no primary checksum provided")
    );
    let primary_expanded = zstd::decode_all(File::open(primary_path).unwrap())
        .expect("failed to decompress primary list");
    assert_eq!(
        &sha256::digest(&primary_expanded),
        primary_data
            .open_checksum
            .text
            .as_ref()
            .expect("no primary open checksum was provided")
    );
    let primary: PrimaryMetadata =
        quick_xml::de::from_str(String::from_utf8(primary_expanded).unwrap().as_str())
            .expect("failed to deserialize primary list");

    // Retrieve a specific package
    let package = match version {
        PackageVersion::Latest => {
            let mut packages = primary.package;
            packages.sort_by_key(|p| {
                (
                    p.version.epoch.clone(),
                    p.version.ver.clone(),
                    p.version.rel.clone(),
                )
            });
            packages.pop().expect("no packages in primary list")
        }
        PackageVersion::Version(v) => primary
            .package
            .into_iter()
            .find(|p| v == p.version.ver)
            .unwrap_or_else(|| panic!("no packages match provided version {v}")),
        PackageVersion::Evr(epoch, version, release) => primary
            .package
            .into_iter()
            .find(|p| {
                epoch == p.version.epoch && version == p.version.ver && release == p.version.rel
            })
            .unwrap_or_else(|| panic!("no packages match provided EVR {version:?}")),
    };

    // Verify the file exists and matches its hash
    let package_path = dir_path.join(&package.location.href);
    assert!(package_path.is_file());
    assert_eq!(
        &sha256::try_digest(package_path).expect("failed to digest package"),
        package
            .checksum
            .text
            .as_ref()
            .expect("no package checksum provided")
    );
    package
}

/// Specify which RPM should be verified from [`PrimaryMetadata`].
///
/// This will only match
#[derive(Debug)]
enum PackageVersion {
    // Retrieves the latest version, based on highest, epoch, then version, then release
    Latest,
    // Retrieves the first package where Version matches this value
    Version(Versioning),
    // Retrieves the first (hopefully only) package with this epoch, version, and release
    #[allow(dead_code)]
    Evr(Versioning, Versioning, Versioning),
}

trait IgnoreErrorKind {
    /// Converts a given [`ErrorKind`] to [`Ok`]
    fn ignore_kind(self, kind: ErrorKind) -> Self;
}

impl IgnoreErrorKind for io::Result<()> {
    fn ignore_kind(self, kind: ErrorKind) -> Self {
        self.or_else(|e| if e.kind() == kind { Ok(()) } else { Err(e) })
    }
}
