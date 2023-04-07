use std::io::stdin;
use std::path::Path;
use std::process::{Command, exit, ExitStatus};

use clap::{arg, Parser};
use hyper::{Body, Client, Uri};
use hyper::client::HttpConnector;
use hyper_rustls::{HttpsConnector, HttpsConnectorBuilder};
use regex::Regex;
use versions::Version;

#[derive(Parser)]
#[command(author, version, about)]
struct UpvadOpts {
    /// View the version of Mullvad VPN to be installed. Testing only, use `mullvad version` instead.
    #[arg(short,long)]
    check: bool,

    /// Install the update without asking
    #[arg(short,long)]
    yes: bool
}

const BASE_URL: &str = "https://mullvad.net";
const DEFAULT_PATH: &str = "/download/app/rpm/latest";

fn main() {
    let https = HttpsConnectorBuilder::new()
        .with_native_roots()
        .https_only()
        .enable_http2()
        .build();

    let client = Client::builder().build(https);
    let opts = UpvadOpts::parse();

    let (latest_url, new_ver) = get_version(&client);

    println!("Newest version is {new_ver}");

    if !&opts.check {
        if !&opts.yes {
            confirm();
        }

        stat_check("wget",
                   Command::new("wget").args(["--content-disposition", &latest_url])
                       .spawn().expect("Unable to execute download command").wait().unwrap());


        // Funny math to get the filename
        let mut install = Command::new("sudo");
        let rpm_path = String::from(
            Path::new(latest_url.rsplit_once('/').unwrap().1)
                .canonicalize().unwrap().to_str().unwrap());

        if opts.yes {
            install.args(["dnf", "-y", "upgrade", &rpm_path])
        } else {
            install.args(["dnf", "upgrade", &rpm_path])
        };

        stat_check("dnf install",
                   install.spawn().expect("Error encountered when executing install command")
                       .wait().unwrap());
        stat_check("rm",
                   Command::new("rm").args(["-rf", &rpm_path]).spawn()
                       .expect("Error encountered when deleting RPM").wait().unwrap());
    }
}

#[tokio::main(flavor = "current_thread")]
async fn get_version(client: &Client<HttpsConnector<HttpConnector>, Body>) -> (String, Version) {
    let mut latest_url = String::from(BASE_URL) + DEFAULT_PATH;

    for _ in 0..8 {
        let uri = latest_url.parse::<Uri>().expect("Unexpected error parsing default URI");
        let resp = client.get(uri)
            .await.unwrap_or_else(|e| panic!("Unable to access {latest_url}\n{e}"));

        if [301, 302].contains(&resp.status().as_u16()) {
            let resp_url: &str = resp.headers().get("location").unwrap()
                .to_str().unwrap();

            if let Some(ver) = Regex::new(r"\d{4}\.\d").unwrap().find(resp_url) {
                return (String::from(resp_url), Version::new(ver.as_str()).unwrap())
            } else {
                // Follow new link
                latest_url = String::from(BASE_URL) + resp_url;
            }
        } else {
            panic!("Expected return code of <302> but was <{}>\nURI: {latest_url}", resp.status())
        }
    }

    panic!("Cancelled: too many redirects");
}

fn confirm () {
    loop {
        println!("Upgrade? [y/N]");
        let mut confirm = String::new();
        stdin().read_line(&mut confirm).unwrap();

        match confirm.to_lowercase().get(0..1) {
            Some("y") => return,
            Some("n") | Some("\r") | Some("\n") | None => {
                println!("Upgrade cancelled.");
                exit(0);
            },
            Some(_) => println!("Invalid input, please try again.\n"),
        }
    }
}

fn stat_check(command: &str, st: ExitStatus) {
    if !st.success() {
        eprintln!("Command {command} exited with status code {}", st.code().unwrap());
        exit(st.code().unwrap());
    }
}