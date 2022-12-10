#!/bin/bash
# Other apps I use, run from this directory

sudo dnf install calibre dconf-editor duplicity ffmpeg gnome-extensions-app openrgb steam virt-manager zoom

# gsettings modifications for RK87 keyboard and dev tool shortcuts
gsettings set org.gnome.desktop.wm.keybindings activate-window-menu "['<Shift><Super>F10']"
gsettings set org.gnome.desktop.wm.keybindings unmaximize "['<Super>Down']"
gsettings set org.gnome.desktop.wm.keybindings toggle-maximized "['']"
gsettings set org.gnome.settings-daemon.plugins.media-keys mic-mute "['AudioStop']"
gsettings set org.gnome.settings-daemon.plugins.media-keys stop-static "['']"

# Google Chrome
sudo dnf config-manager --set-enabled google-chrome
sudo dnf check-update

# ExpressVPN (see _expressvpn-upgrade.py)
cp ./*expressvpn* ~/scripts # Convenient script to upgrade expressvpn via CLI
sudo chmod ug+x ./*expressvpn*
expressvpn-upgrade --install

# vnStat for cool network info
sudo dnf install vnstat
sudo systemctl enable vnstat
sudo systemctl start vnstat

# Flatpaks (slight brace expansion abuse)
sudo flatpak install \
    cc.arduino.IDE2 \
    com.discordapp.Discord \
    com.github.tchx84.Flatseal \
    com.obsproject.Studio \
    com.slack.Slack \
    com.spotify.Client \
    com.ulduzsoft.Birdtray \
    io.github.Qalculate \
    io.github.trigg.discover_overlay \
    md.obsidian.Obsidian \
    nl.hjdskes.gcolor3 \
    org.gimp.GIMP{,.Plugin.{BIMP,Fourier,Lensfun,LiquidRescale,Resynthesizer}} \
    org.mozilla.Thunderbird \
    org.signal.Signal \
    tech.feliciano.pocket-casts

sudo flatpak override --env=TERM=xterm-color --env=LC_MONETARY=en_CA.UTF-8 io.github.Qalculate

# Snaps
sudo snap install authy kochmorse

# Manually installed as needed: MultiMC, DaVinci Resolve
