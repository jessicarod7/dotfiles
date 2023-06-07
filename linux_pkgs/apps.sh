#!/bin/bash
# Run from this directory
if [[ ! "$(dirname $(pwd))" =~ "/linux_pkgs" ]]; then
    echo "Please run this script from within the \`linux_pkgs\` directory"
    exit 1
fi

# Other apps I use
sudo dnf -y install dconf-editor duplicity ffmpeg openrgb steam virt-manager zoom pandoc qalculate qalculate-gtk
pip install trash-cli 'trash-cli[completion]'

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
# - sound-output-device-chooser@kgshank.net (currently unsupported, see kgshank/gse-sound-output-chooser#258)

# gsettings modifications for RK87 keyboard and dev tool shortcuts
gsettings set org.gnome.desktop.wm.keybindings activate-window-menu "['<Shift><Super>F10']"
gsettings set org.gnome.desktop.wm.keybindings unmaximize "['<Super>Down']"
gsettings set org.gnome.desktop.wm.keybindings toggle-maximized "['']"
gsettings set org.gnome.settings-daemon.plugins.media-keys mic-mute "['AudioStop']"
gsettings set org.gnome.settings-daemon.plugins.media-keys stop-static "['']"

# ExpressVPN (see _expressvpn-upgrade.py)
cp ./*expressvpn* ~/scripts # Convenient script to upgrade expressvpn via CLI
sudo chmod ug+x ./*expressvpn*
expressvpn-upgrade --install

# vnStat for cool network info
sudo dnf -y install vnstat
sudo systemctl enable vnstat
sudo systemctl start vnstat

# Flatpaks (slight brace expansion abuse)
sudo flatpak install --noninteractive \
    cc.arduino.IDE2 \
    com.authy.Authy \
    com.belmoussaoui.Decoder \
    com.calibre_ebook.calibre \
    com.discordapp.Discord \
    com.github.finefindus.eyedropper \
    com.github.flxzt.rnote \
    com.github.liferooter.textpieces \
    com.github.maoschanz.drawing \
    com.github.tchx84.Flatseal \
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
    org.signal.Signal \
    tech.feliciano.pocket-casts

# Pastel (with desktop color picker)
yes | cargo install pastel
sudo appstreamcli put pastel/pastel.metainfo.xml
cp pastel/pastel.desktop ~/.local/share/applications/pastel.desktop
cp pastel/pastel-256.png ~/.local/share/icons/hicolor/256x256/apps/pastel.png

# Setup Evolution toolbar
mkdir -p ~/.var/app/org.gnome.Evolution/config/evolution/ui
cp ./evolution-mail-reader.ui ~/.var/app/org.gnome.Evolution/config/evolution/ui


# Systemd updaters
cp ../systemd/* multiviewer/multiviewer-repo.service multiviewer/multiviewer-repo.timer "$XDG_CONFIG_HOME/systemd/user/"
sed -i "s/<USER>/$USER/" "$XDG_CONFIG_HOME/systemd/user/*.service"
systemctl --user daemon-reload
systemctl --user enable --now \
  local_updchk@rustup.timer
  local_updchk@rbenv.timer
  local_updchk@vimplug.timer
  local_updchk@pastel-chk.timer
  local_updchk@cargo-whatfeatures.timer

# Multiviewer
mkdir -p "$XDG_DATA_HOME/localrepos/multiviewer/x86_64/"
cp multiviewer/multiviewer-repo.py ~/scripts
systemctl --user enable --now multiviewer-repo.timer
sudo cp multiviewer/multiviewer.repo /etc/yum.repos.d/
sudo sed -i "s/<USER>/$USER/" /etc/yum.repos.d/multiviewer.repo
printf 'When you'\''re ready, run %s\n' '`dnf install multiviewer-for-f1`'


# Manually installed as needed: DaVinci Resolve
