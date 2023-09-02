#!/bin/bash
# Run from this directory
if [[ ! "$(dirname $(pwd))" =~ "/linux_pkgs" ]]; then
    echo "Please run this script from within the \`linux_pkgs\` directory"
    exit 1
fi

# Other apps I use
sudo dnf -y install dconf-editor duplicity openrgb steam virt-manager pandoc qalculate qalculate-gtk
sudo dnf -y swap ffmpeg-free ffmpeg --allowerasing
pip install trash-cli 'trash-cli[completion]'
yes | cargo install pastel

# Howdy
# sudo dnf -y enable principis/howdy && sudo dnf -y install howdy
# sudo bash ../scripts/howdy/howdy_camrod.sh && sudo semodule -i howdy_camrod.pp

# Setup flathub-beta, prioritize default Flathub repo
sudo flatpak remote-add --if-not-exists flathub-beta https://flathub.org/beta-repo/flathub-beta.flatpakrepo
sudo flatpak remote-modify flathub --prio=2

# GNOME Extensions
sudo flatpak install com.mattjakeman.ExtensionManager
# Extensions:
# - appindicatorsupport@rgcjonas.gmail.com
# - clipboard-history@alexsaveau.dev
# - expandable-notifications@kaan.g.inam.org
# - improvedosk@nick-shmyrev.dev (see nick-shmyrev/improved-osk-gnome-ext#30)
# - NotificationCounter@coolllsk
# - openweather-extension@jenslody.de
# - simple-timer@majortomvr.github.com

# gsettings modifications for RK84 keyboard and dev tool shortcuts
gsettings set org.gnome.desktop.wm.keybindings activate-window-menu "['<Shift><Super>F10']"
gsettings set org.gnome.desktop.wm.keybindings unmaximize "['<Super>Down']"
gsettings set org.gnome.desktop.wm.keybindings toggle-maximized "['']"
gsettings set org.gnome.settings-daemon.plugins.media-keys mic-mute "['AudioStop']"
gsettings set org.gnome.settings-daemon.plugins.media-keys stop-static "['']"

# Flatpaks (slight brace expansion abuse)
sudo flatpak install --noninteractive \
    cc.arduino.IDE2 \
    com.authy.Authy \
    com.belmoussaoui.Decoder \
    com.calibre_ebook.calibre \
    com.discordapp.Discord \
    com.github.finefindus.eyedropper \
    com.github.liferooter.textpieces \
    com.github.maoschanz.drawing \
    com.github.tchx84.Flatseal \
    com.github.xournalpp.xournalpp \
    com.obsproject.Studio \
    com.slack.Slack \
    com.spotify.Client \
    io.github.Qalculate \
    io.github.trigg.discover_overlay \
    md.obsidian.Obsidian \
    org.gimp.GIMP{,.Plugin.{BIMP,Fourier,Lensfun,LiquidRescale,Resynthesizer}} \
    org.gnome.design.IconLibrary \
    org.gnome.Evolution \
    org.kde.okular \
    org.prismlauncher.PrismLauncher \
    org.signal.Signal//beta \

# Setup Xournal++
mkdir -p ~/.var/app/com.github.xournalpp.xournalpp/config/xournalpp
cp ../xournalpp/settings.xml ~/.var/app/com.github.xournalpp.xournalpp/config/xournalpp/settings.xml

# Systemd updaters
mkdir -p "$XDG_CONFIG_HOME/systemd/user/"
cp ../systemd/* \
    localrepos/multiviewer/multiviewer-repo.service localrepos/multiviewer/multiviewer-repo.timer \
    localrepos/zoom/zoom-repo.service localrepos/zoom/zoom-repo.timer \
    "$XDG_CONFIG_HOME/systemd/user/"
cp localrepos/python_scripts/update_repo.py ~/scripts/
sed -i "s/<USER>/$(id -un)/" "$XDG_CONFIG_HOME/systemd/user/*.service"
systemctl --user daemon-reload
systemctl --user enable --now \
  local_updchk@handlr-regex.timer \
  local_updchk@rustup-chk.timer \
  local_updchk@rbenv-chk.timer \
  local_updchk@vimplug-chk.timer \
  local_updchk@pastel-chk.timer \
  local_updchk@poetry-chk.timer \
  local_updchk@cargo-whatfeatures-chk.timer

# Multiviewer
mkdir -p "$XDG_DATA_HOME/localrepos/multiviewer/x86_64/"
cp localrepos/python_scripts/multiviewer-repo.py ~/scripts
systemctl --user enable --now multiviewer-repo.timer
sleep 10
sudo cp localrepos/multiviewer/multiviewer.repo /etc/yum.repos.d/
sudo sed -i "s/<USER>/$(id -un)/" /etc/yum.repos.d/multiviewer.repo
printf 'When you'\''re ready, run %s\n' '`dnf install multiviewer-for-f1`'

# Zoom
mkdir -p "$XDG_DATA_HOME/localrepos/zoom/x86_64/"
cp localrepos/python_scripts/zoom-repo.py ~/scripts
systemctl --user enable --now zoom-repo.timer
sleep 10
sudo cp localrepos/zoom/zoom.repo /etc/yum.repos.d/
sudo sed -i "s/<USER>/$(id -un)/" /etc/yum.repos.d/zoom.repo
sudo rpm --import 'https://zoom.us/linux/download/pubkey?version=5-12-6'
printf 'When you'\''re ready, run %s\n' '`dnf install zoom`'

# Manually installed as needed: DaVinci Resolve
