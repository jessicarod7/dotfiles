use std::io::stdin;
use std::path::Path;
use std::process::{Command, exit, ExitStatus};
use std::str::from_utf8;

use clap::{arg, Parser};
use hyper::{Body, Client, Uri};
use hyper::client::HttpConnector;
use hyper_rustls::{HttpsConnector, HttpsConnectorBuilder};
use itertools::Itertools;
use regex::Regex;
use versions::Version;

#[derive(Parser)]
#[command(author, version, about)]
struct UpvadOpts {
    /// Do not install; view the current and newest versions of Mullvad.
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
    let vmatch = Regex::new(r"\d{4}\.\d").unwrap();
    let parse_msg = || { eprintln!("Unable to parse version string from `mullvad version`. Will not check against current version."); };

    let (latest_url, new_ver) = get_version(&client, &vmatch);

    let mull_ver_cmd = Command::new("mullvad").arg("version").output().expect("Unable to check installed Mullvad version");
    stat_check("mullvad", mull_ver_cmd.status);

    if let Ok(mull_ver) = from_utf8(&mull_ver_cmd.stdout) {
        if let Some((curr_ver_ln, _, rec_update_ln)) = mull_ver.lines().take(3).collect_tuple() {
            let curr_str = vmatch.find(curr_ver_ln);
            if let Some(curr_ver) = curr_str {
                if !print_upgrades(&Version::new(curr_ver.as_str()).unwrap(), &new_ver,   rec_update_ln, opts.check) {
                    exit(0);
                }
            }
        } else {
            parse_msg();
        }
    } else {
        eprintln!("Mullvad version string could not be converted to string. Will not check against current version.");
    }


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
async fn get_version(client: &Client<HttpsConnector<HttpConnector>, Body>, vmatch: &Regex) -> (String, Version) {
    let mut latest_url = String::from(BASE_URL) + DEFAULT_PATH;

    for _ in 0..8 {
        let uri = latest_url.parse::<Uri>().expect("Unexpected error parsing default URI");
        let resp = client.get(uri)
            .await.unwrap_or_else(|e| panic!("Unable to access {latest_url}\n{e}"));

        if [301, 302].contains(&resp.status().as_u16()) {
            let resp_url: &str = resp.headers().get("location").unwrap()
                .to_str().unwrap();

            if let Some(ver) = vmatch.find(resp_url) {
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


/// Reports if there is an available update. Returns if an upgrade should be offered.
fn print_upgrades(curr_ver: &Version, new_ver: &Version, rec_update: &str, check: bool) -> bool {
    let update_recommended = !rec_update.contains("none");

    println!("Current version is {curr_ver}");
    if new_ver > curr_ver {
        println!("There is an {} update to {new_ver} available", if update_recommended {"recommended"} else {"optional"});
        true
    } else if curr_ver > new_ver {
        println!("However, the newest listed version is {new_ver}{} -- you should check https://mullvad.net and see if a downgrade is needed.", if update_recommended {" (with an \"update\" recommended)"} else {""});
        return false
    } else if update_recommended {
        println!("This is the newest version, however the VPN is recommending an upgrade anyways -- you should check https://mullvad.net for details");
        false
    } else {
        println!("This is the newest available version{}", if !check {", upgrade will be cancelled"} else {""});
        false
    }
}