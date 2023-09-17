# Run from an administrator pwsh.exe (requires `winget install Microsoft.PowerShell`)
winget settings --enable InstallerHashOverride
winget install --verbose --accept-package-agreements --accept-source-agreements --disable-interactivity `
Microsoft.VCRedist.2015+.x64 Microsoft.VisualStudio.2022.BuildTools `
Google.Chrome Obsidian.Obsidian `
AgileBits.1Password.Beta Twilio.Authy Yubico.Authenticator `
Git.Git GitHub.cli GnuPG.GnuPG `
Rustlang.Rustup Microsoft.VisualStudioCode JetBrains.Toolbox vim.vim `
BurntSushi.ripgrep.MSVC sharkdp.fd `
Discord.Discord OpenWhisperSystems.Signal.Beta SlackTechnologies.Slack.Beta `
Intel.IntelDriverAndSupportAssistant Microsoft.PowerToys Mozilla.Firefox REALiX.HWiNFO Qalculate.Qalculate Spotify.Spotify Xournal++.Xournal++ `
9NXQXXLFST89 9PCDBQX582BZ 9NKSQGP7F2NH
<# 9NXQXXLFST89 is Disney+, PCDBQX582BZ is Pocket Casts, 9NKSQGP7F2NH is WhatsApp #>

winget install --verbose --accept-package-agreements --accept-source-agreements --disable-interactivity --include-unknown AirVPN.Eddie

# Note that Google.Chrome, Spotify.Spotify, and AgileBits.1Password.Beta are likely to fail somehow
