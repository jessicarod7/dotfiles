#![cfg_attr(docsrs, feature(doc_auto_cfg))]

use std::process::ExitCode;

use clap::Parser;
use reqwest::blocking::Client;

use multiviewer_repo::Cli;

fn main() -> ExitCode {
    let args = Cli::parse();
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
