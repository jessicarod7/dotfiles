//! See [OpenSUSE's specification](https://en.opensuse.org/openSUSE:Standards_Rpm_Metadata)

use serde::{Deserialize, Serialize};
use versions::Versioning;

#[derive(Serialize, Deserialize)]
pub struct PrimaryMetadata {
    #[serde(rename = "@xmlns")]
    pub xmlns: String,
    #[serde(rename = "@xmlns:rpm")]
    pub xmlns_rpm: String,
    #[serde(rename = "@packages")]
    pub packages: String,
    #[serde(rename = "$text")]
    pub text: Option<String>,
    pub package: Vec<Package>,
}

#[derive(Serialize, Deserialize)]
pub struct Package {
    #[serde(rename = "@type")]
    pub package_type: String,
    #[serde(rename = "$text")]
    pub text: Option<String>,
    pub name: String,
    pub arch: String,
    pub version: Version,
    pub checksum: Checksum,
    pub summary: String,
    pub description: String,
    pub packager: Packager,
    pub url: String,
    pub time: Time,
    pub size: Size,
    pub location: Location,
    pub format: Format,
}

#[derive(Serialize, Deserialize)]
pub struct Version {
    #[serde(rename = "@epoch", deserialize_with = "Versioning::deserialize_pretty")]
    pub epoch: Versioning,
    #[serde(rename = "@ver", deserialize_with = "Versioning::deserialize_pretty")]
    pub ver: Versioning,
    #[serde(rename = "@rel", deserialize_with = "Versioning::deserialize_pretty")]
    pub rel: Versioning,
}

#[derive(Serialize, Deserialize)]
pub struct Checksum {
    #[serde(rename = "@type")]
    pub checksum_type: String,
    #[serde(rename = "@pkgid")]
    pub pkgid: String,
    #[serde(rename = "$text")]
    pub text: Option<String>,
}

#[derive(Serialize, Deserialize)]
pub struct Packager {}

#[derive(Serialize, Deserialize)]
pub struct Time {
    #[serde(rename = "@file")]
    pub file: String,
    #[serde(rename = "@build")]
    pub build: String,
}

#[derive(Serialize, Deserialize)]
pub struct Size {
    #[serde(rename = "@package")]
    pub package: String,
    #[serde(rename = "@installed")]
    pub installed: String,
    #[serde(rename = "@archive")]
    pub archive: String,
}

#[derive(Serialize, Deserialize)]
pub struct Location {
    #[serde(rename = "@href")]
    pub href: String,
}

#[derive(Serialize, Deserialize)]
pub struct Format {
    #[serde(rename = "$text")]
    pub text: Option<String>,
    #[serde(rename = "license")]
    pub rpm_license: String,
    #[serde(rename = "vendor")]
    pub rpm_vendor: RpmVendor,
    #[serde(rename = "group")]
    pub rpm_group: String,
    #[serde(rename = "buildhost")]
    pub rpm_buildhost: String,
    #[serde(rename = "sourcerpm")]
    pub rpm_sourcerpm: String,
    #[serde(rename = "header-range")]
    pub rpm_header_range: RpmHeaderRange,
    #[serde(rename = "provides")]
    pub rpm_provides: RpmProvides,
    #[serde(rename = "requires")]
    pub rpm_requires: RpmRequires,
    pub file: String,
}

#[derive(Serialize, Deserialize)]
pub struct RpmVendor {}

#[derive(Serialize, Deserialize)]
pub struct RpmHeaderRange {
    #[serde(rename = "@start")]
    pub start: String,
    #[serde(rename = "@end")]
    pub end: String,
}

#[derive(Serialize, Deserialize)]
pub struct RpmProvides {
    #[serde(rename = "$text")]
    pub text: Option<String>,
    #[serde(rename = "entry")]
    pub rpm_entry: Vec<RpmProvidesRpmEntry>,
}

#[derive(Serialize, Deserialize)]
pub struct RpmProvidesRpmEntry {
    #[serde(rename = "@name")]
    pub name: String,
    #[serde(rename = "@flags")]
    pub flags: String,
    #[serde(rename = "@epoch")]
    pub epoch: String,
    #[serde(rename = "@ver")]
    pub ver: String,
    #[serde(rename = "@rel")]
    pub rel: String,
}

#[derive(Serialize, Deserialize)]
pub struct RpmRequires {
    #[serde(rename = "$text")]
    pub text: Option<String>,
    #[serde(rename = "entry")]
    pub rpm_entry: Vec<RpmRequiresRpmEntry>,
}

#[derive(Serialize, Deserialize)]
pub struct RpmRequiresRpmEntry {
    #[serde(rename = "@name")]
    pub name: String,
}
