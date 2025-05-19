//! See [OpenSUSE's specification](https://en.opensuse.org/openSUSE:Standards_Rpm_Metadata)

use serde::{Deserialize, Serialize};

#[derive(Serialize, Deserialize)]
pub struct Repomd {
    #[serde(rename = "@xmlns")]
    pub xmlns: String,
    #[serde(rename = "@xmlns:rpm")]
    pub xmlns_rpm: String,
    #[serde(rename = "$text")]
    pub text: Option<String>,
    pub revision: String,
    pub data: Vec<Data>,
}

#[derive(Serialize, Deserialize)]
pub struct Data {
    #[serde(rename = "@type")]
    pub data_type: String,
    #[serde(rename = "$text")]
    pub text: Option<String>,
    pub checksum: Checksum,
    #[serde(rename = "open-checksum")]
    pub open_checksum: OpenChecksum,
    pub location: Location,
    pub timestamp: String,
    pub size: String,
    #[serde(rename = "open-size")]
    pub open_size: String,
}

#[derive(Serialize, Deserialize)]
pub struct Checksum {
    #[serde(rename = "@type")]
    pub checksum_type: String,
    #[serde(rename = "$text")]
    pub text: Option<String>,
}

#[derive(Serialize, Deserialize)]
pub struct OpenChecksum {
    #[serde(rename = "@type")]
    pub open_checksum_type: String,
    #[serde(rename = "$text")]
    pub text: Option<String>,
}

#[derive(Serialize, Deserialize)]
pub struct Location {
    #[serde(rename = "@href")]
    pub href: String,
}
