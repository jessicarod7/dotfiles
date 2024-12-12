use std::io::{Result, Write};
use std::process::{Command, ExitCode, ExitStatus, Output};

use clap::builder::PossibleValue;
use clap::Parser;
use clap::ValueEnum;
use directories::ProjectDirs;
use serde::Deserialize;
use tempfile::NamedTempFile;

#[derive(Copy, Clone, Debug, Eq, PartialEq)]
enum KeyidFormat {
    None,
    Short,
    /// Oxshort
    HexShort,
    Long,
    /// 0xlong
    HexLong,
}

impl ValueEnum for KeyidFormat {
    fn value_variants<'a>() -> &'a [Self] {
        &[
            Self::None,
            Self::Short,
            Self::HexShort,
            Self::Long,
            Self::HexLong,
        ]
    }

    fn to_possible_value(&self) -> Option<PossibleValue> {
        Some(match self {
            Self::None => PossibleValue::new("none"),
            Self::Short => PossibleValue::new("short"),
            Self::HexShort => PossibleValue::new("0xshort"),
            Self::Long => PossibleValue::new("long"),
            Self::HexLong => PossibleValue::new("0xlong"),
        })
    }
}

/// Config options to specify signing credentials.
///
/// Source file:
///
/// ```
/// use directories::ProjectDirs;
///
/// let config_file = ProjectDirs::from("", "", env!("CARGO_PKG_NAME"))
///     .unwrap()
///     .config_dir()
///     .join("");
/// ```
#[derive(Clone, Debug, Deserialize)]
struct ToolConfig {
    /// ID of the GPG signing key (see Git's
    /// [`user.signingkey`](https://git-scm.com/docs/git-config#Documentation/git-config.txt-usersigningKey))
    signing_key: String,
    /// If provided, full 1Password secret reference for the GPG key passphrase
    op_secret_reference: Option<String>,
    /// If provided, prompt title for a password salt.
    salt_name: Option<String>,
    /// If provided, insert location for password salt. Only effective if
    /// [`ToolConfig::op_secret_reference`] is specified.
    salt_location: Option<usize>,
}

/// CLI arguments which implement the requirements of Git's [`gpg.program`][gpg.prog], as of
/// Git 2.47.1.
/// 
/// [gpg.prog]: https://git-scm.com/docs/git-config#Documentation/git-config.txt-gpgprogram
#[derive(Debug, Parser)]
struct Cli {
    /// Make a detached signature
    #[arg(short = 'b', long)]
    detach_sign: bool,
    /// Sign a message. This command may be combined with --encrypt (to sign and encrypt a
    /// message), --symmetric (to sign and symmetrically encrypt a message), or both --encrypt and
    /// --symmetric (to sign and encrypt a message that can be decrypted using a secret key or a
    /// passphrase).  The signing  key is chosen by default or can be set explicitly using the
    /// --local-user and --default-key options.
    #[arg(short, long)]
    sign: bool,
    /// Create ASCII armored output.  The default is to create the binary OpenPGP format.
    #[arg(short, long)]
    armor: bool,
    /// Use name as the key to sign with. Note that this option overrides --default-key.
    #[arg(short = 'u', long)]
    local_user: Option<String>,
    /// Select how to display key IDs.  "none" does not show the key ID at all but shows the
    /// fingerprint in a separate line.  "short" is the traditional 8-character key ID.  "long" is
    /// the more accurate (but less convenient) 16-character key ID.  Add an "0x" to either to
    /// include an "0x" at the beginning of the key ID, as in 0x99242560.  Note that this
    /// option is ignored if the option --with-colons is used.
    #[arg(short, long, value_enum)]
    keyid_format: Option<KeyidFormat>,
    /// Assume that the first argument is a signed file and verify it without generating any
    /// output.  With no arguments, the signature packet is read from STDIN.  If only one argument
    /// is given, the specified file is expected to include a complete signature.
    ///
    /// With more than one argument, the first argument should specify a file with a detached
    /// signature and the remaining files should contain the signed data. To read the signed data
    /// from STDIN, use ‘-’ as the second filename.  For security reasons, a detached signature
    /// will not read the signed  material from STDIN if not explicitly specified.
    ///
    /// Note: If the option --batch is not used, gpg may assume that a single argument is a file
    /// with a detached signature, and it will try to find a matching data file by stripping
    /// certain suffixes.  Using this historical feature to verify a detached signature is strongly
    /// discouraged; you should always specify the data file explicitly.
    ///
    /// Note:  When  verifying  a cleartext signature, gpg verifies only what makes up the
    /// cleartext signed data and not any extra data outside of the cleartext signature or the
    /// header lines directly following the dash marker line.  The option --output may be used to
    /// write out the actual signed data, but there are other pitfalls with this format as
    /// well.  It is suggested to avoid cleartext signatures in favor of detached signatures.
    ///
    /// Note: To check whether a file was signed by a certain key the option --assert-signer can be
    /// used.  As an alternative the gpgv tool can be used.  gpgv is designed to compare signed
    /// data against a list of trusted keys and returns with success only for a good signature.  It
    /// has  its  own  manual page.
    #[arg(long)]
    verify: Option<String>,
    /// Write special status strings to the file descriptor n.  See the file DETAILS in the
    /// documentation for a listing of them.
    #[arg(long)]
    status_fd: Option<usize>,
    /// This just exists to catch "-" in verify commands.
    #[arg(trailing_var_arg = true)]
    stdin_capture: Option<String>,
}

fn main() -> ExitCode {
    let args = Cli::parse();
    let config_file = ProjectDirs::from("", "", env!("CARGO_PKG_NAME"))
        .unwrap()
        .config_dir()
        .join("config.toml");
    let config: ToolConfig =
        toml::from_str(&std::fs::read_to_string(&config_file).expect("failed to load config file"))
            .expect("failed to parse tool config");

    if args.detach_sign && args.sign && args.armor && args.local_user.is_some() {
        let status = git_sign(&args, &config).expect("failed to sign");
        if status.success() {
            ExitCode::SUCCESS
        } else {
            ExitCode::from(status.code().unwrap() as u8)
        }
    } else if args.verify.is_some() {
        let status = git_verify(&args).expect("failed to verify");
        ExitCode::from(status.code().unwrap() as u8)
    } else {
        panic!("unrecognized command")
    }
}

fn git_sign(args: &Cli, config: &ToolConfig) -> Result<ExitStatus> {
    let mut sign_command = Command::new("gpg");

    if let Some(status_fd) = args.status_fd {
        sign_command.args(["--status-fd", &status_fd.to_string()]);
    }

    sign_command.args(["-bsau", args.local_user.as_ref().unwrap()]);

    if args
        .local_user
        .as_ref()
        .is_some_and(|user| user == &config.signing_key)
    {
        // Pull base GPG passphrase from 1Password CLI
        let base_passphrase = if let Some(op_secret_reference) = &config.op_secret_reference {
            Command::new("op")
                .args(["read", op_secret_reference])
                .output()
                .stringify("base passphrase")
        } else {
            None
        };

        // Query for salt
        let salt = if base_passphrase.is_some() {
            let salt_name = config.salt_name.to_owned().unwrap_or("salt".to_string());
            Command::new("zenity")
                .args(["--title", &format!("Provide {salt_name}"), "--password"])
                .output()
                .stringify(&salt_name)
        } else {
            None
        };

        // Assemble passphrase
        let full_passphrase = if let (Some(base), Some(salt)) = (base_passphrase, salt) {
            let salt_loc = config.salt_location.unwrap_or(base.len());
            match (base.get(0..salt_loc), base.get(salt_loc..)) {
                (Some(front), Some(back)) => Some(format!("{front}{salt}{back}")),
                _ => {
                    eprintln!("invalid base passphrase");
                    None
                }
            }
        } else {
            None
        };

        // Add to command
        if let Some(full) = full_passphrase {
            // Create a temp passphrase file
            let mut passfile = NamedTempFile::new().expect("unable to create temp passphrase file");
            write!(passfile, "{}", full).expect("unable to write to temp passphrase file");

            sign_command.args([
                "--batch",
                "--pinentry-mode",
                "loopback",
                "--passphrase-file",
                &format!("{}", passfile.path().display()),
            ]);
            let result = sign_command.status();
            passfile
                .close()
                .expect("failed to close temp passphrase file");
            return result;
        } else {
            eprintln!("will perform normal GPG passphrase request");
        }
    }

    sign_command.status()
}

fn git_verify(args: &Cli) -> Result<ExitStatus> {
    let mut verify_command = Command::new("gpg");

    if let Some(format) = args.keyid_format {
        verify_command.args([
            "--keyid-format",
            format.to_possible_value().unwrap().get_name(),
        ]);
    }

    if let Some(status_fd) = args.status_fd {
        verify_command.args(["--status-fd", &status_fd.to_string()]);
    }

    verify_command.args(["--verify", args.verify.as_ref().unwrap(), "-"]);

    verify_command.status()
}

trait StringifyOutput {
    fn stringify(self, type_name: &str) -> Option<String>;
}

impl StringifyOutput for Result<Output> {
    fn stringify(self, type_name: &str) -> Option<String> {
        match self {
            Ok(out) => {
                if !out.status.success() {
                    eprintln!(
                        "failed to retrieve {type_name}, status {:?}",
                        out.status.code()
                    );
                    None
                } else {
                    String::from_utf8(out.stdout).map_or_else(
                        |_| {
                            eprintln!("{type_name} is not UTF-8");
                            None
                        },
                        |result| Some(result.trim().to_string()),
                    )
                }
            }
            Err(err) => {
                eprintln!("failed to retrieve {type_name}: {err}");
                None
            }
        }
    }
}
