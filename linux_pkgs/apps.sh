#!/bin/bash
# Run from this directory
if [[ ! "$(dirname $(pwd))" =~ "/linux_pkgs" ]]; then
    echo "Please run this script from within the \`linux_pkgs\` directory"
    exit 1
fi

# Other apps I use
sudo dnf -y install dconf-editor duplicity ffmpeg openrgb steam virt-manager zoom

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
    org.gnome.Evolution \
    org.prismlauncher.PrismLauncher \
    org.signal.Signal \
    tech.feliciano.pocket-casts

sudo flatpak override --env=TERM=xterm-256color --env=LC_MONETARY=en_CA.UTF-8 io.github.Qalculate

# Cargo (Rust)
yes | cargo install pastel
sudo appstreamcli put pastel/pastel.metainfo.xml
cp pastel/pastel.desktop ~/.local/share/applications/pastel.desktop
cp pastel/pastel-256.png ~/.local/share/icons/hicolor/256x256/apps/pastel.png

# Setup Evolution toolbar
mkdir -p ~/.var/app/org.gnome.Evolution/config/evolution/ui
cp ./evolution-mail-reader.ui ~/.var/app/org.gnome.Evolution/config/evolution/ui

# Manually installed as needed: DaVinci Resolve
