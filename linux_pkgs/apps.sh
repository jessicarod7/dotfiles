#!/bin/bash
# Run from this directory
if [[ ! $(dirname "$PWD") =~ "/linux_pkgs" ]]; then
    echo "Please run this script from within the \`linux_pkgs\` directory"
    exit 1
fi

# Other apps I use
sudo dnf -y install dconf-editor duplicity openrgb steam virt-manager pandoc qalculate
sudo dnf -y swap ffmpeg-free ffmpeg --allowerasing
uv tool install 'trash-cli[completion]'
for cmd in trash-empty trash-list trash-restore trash-put trash; do
  $cmd --print-completion bash | tee "$XDG_DATA_HOME/bash-completion/completions/$cmd";
done

LOCKED_CARGO_BINARIES=(evcxr_repl cargo-audit cynic-cli cargo-msrv)
cargo install --keep-going cargo-update cargo-expand envsh
cargo install --keep-going --locked "${LOCKED_CARGO_BINARIES[@]}"
for b in "${LOCKED_CARGO_BINARIES[@]}"; do
  cargo install-update-config --enforce-lock "$b"
done
unset LOCKED_CARGO_BINARIES

go install github.com/maksimov/epoch@latest

# Setup flathub-beta, prioritize default Flathub repo
sudo flatpak remote-add --if-not-exists flathub-beta https://flathub.org/beta-repo/flathub-beta.flatpakrepo
sudo flatpak remote-modify flathub --prio=2

# Extensions:
# - appindicatorsupport@rgcjonas.gmail.com
# - clipboard-history@alexsaveau.dev
# - emoji-copy@felipeftn
# - enhancedosk@cass00.github.io
# - NotificationCounter@coolllsk
# - openweather-extension@penguin-teal.github.io
# - pip-on-top@rafostar.github.com
# - windowsgestures@extension.amarullz.com

# gsettings modifications for RK84 keyboard and dev tool shortcuts
gsettings set org.gnome.desktop.wm.keybindings activate-window-menu "['<Shift><Super>F10']"
gsettings set org.gnome.desktop.wm.keybindings unmaximize "['<Super>Down']"
gsettings set org.gnome.desktop.wm.keybindings toggle-maximized "['']"
gsettings set org.gnome.settings-daemon.plugins.media-keys mic-mute "['AudioStop']"
gsettings set org.gnome.settings-daemon.plugins.media-keys stop-static "['']"
gsettings set org.gnome.software packaging-format-preference "['flatpak:flathub', 'flatpak:flathub-beta', 'flatpak:fedora', 'flatpak:fedora-testing', 'rpm']"

# Flatpaks (slight brace expansion abuse)
sudo flatpak install \
    cc.arduino.IDE2 \
    com.authy.Authy \
    com.belmoussaoui.Decoder \
    com.calibre_ebook.calibre \
    com.discordapp.Discord \
    com.github.finefindus.eyedropper \
    com.github.flxzt.rnote \
    com.github.jeromerobert.pdfarranger \
    com.github.liferooter.textpieces \
    com.github.maoschanz.drawing \
    com.github.tchx84.Flatseal \
    com.obsproject.Studio \
    com.slack.Slack \
    com.spotify.Client \
    de.philippun1.turtle \
    io.github.Qalculate \
    io.github.trigg.discover_overlay \
    md.obsidian.Obsidian \
    org.gimp.GIMP{,.Plugin.{BIMP,Fourier,Lensfun,LiquidRescale,Resynthesizer}} \
    org.gnome.seahorse.Application \
    org.gnome.design.IconLibrary \
    org.gnome.Evolution \
    org.kde.kwrite \
    org.kde.okular \
    org.prismlauncher.PrismLauncher
sudo flatpak install flathub-beta org.signal.Signal

# Setup KWrite
mkdir -p "$HOME/.var/app/org.kde.kwrite/config/KDE"
cp ../kwrite/kwriterc "$HOME/.var/app/org.kde.kwrite/config/kwriterc"
cp ../kwrite/KDE/Sonnet.conf "$HOME/.var/app/org.kde.kwrite/config/KDE/Sonnet.conf"

# Systemd updaters
mkdir -p "$XDG_CONFIG_HOME/systemd/user/"
cp ../systemd/* \
    localrepos/multiviewer/multiviewer-repo.service localrepos/multiviewer/multiviewer-repo.timer \
    "$XDG_CONFIG_HOME/systemd/user/"
for systemd_file in $(fd '\.service$' "$XDG_CONFIG_HOME/systemd/user/"
); do
    sed -i "s/<USER>/$(id -un)/" "$systemd_file"
done
systemctl --user daemon-reload
systemctl --user enable --now \
  local_updchk@rbenv-chk.timer \
  local_updchk@vimplug-chk.timer \

# Multiviewer
mkdir -p "$XDG_DATA_HOME/localrepos/multiviewer/x86_64/"
cargo install --path localrepos/crates/multiviewer_repo
systemctl --user enable --now multiviewer-repo.timer
sleep 10
sudo cp localrepos/multiviewer/multiviewer.repo /etc/yum.repos.d/
sudo sed -i "s/<USER>/$(id -un)/" /etc/yum.repos.d/multiviewer.repo
sudo dnf makecache
# shellcheck disable=SC2016
printf 'When you'\''re ready, run %s\n' '`dnf install multiviewer-for-f1`'

# Turtle (Git in file manager)
sudo dnf -y install python-pygit2 nautilus-python meld
git clone https://gitlab.gnome.org/philippun1/turtle.git "$HOME/Documents/turtle"
pushd "$HOME/Documents/turtle" || exit
sudo python install.py install --flatpak
popd || exit

# Add support for Stadia controller
sudo cp ./70-stadiacontroller-flash.rules /etc/udev/rules.d
sudo udevadm control --reload-rules && sudo udevadm trigger
