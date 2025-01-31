#!/bin/bash
# Run from this directory
if [[ ! $(dirname "$(pwd)") =~ "/linux_pkgs" ]]; then
    echo "Please run this script from within the \`linux_pkgs\` directory"
    exit 1
fi

# RPM Fusion, other nonfree libraries, first updates, core packages
echo 'max_parallel_downloads=15' | sudo tee -a /etc/dnf/dnf.conf
sudo dnf makecache
sudo dnf -y upgrade
sudo dnf -y install "https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm" \
 "https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm" \
 fedora-workstation-repositories
sudo dnf -y install vim-enhanced ripgrep fd-find

## Fish shell
sudo dnf -y install fish
fish -c 'curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher install jorgebucaran/fisher'
# Run this command interactively in fish after installing JetBrains Mono Nerd Font: fisher install IlanCosman/tide@v6
# > Lean, True color, No time, One line, Compact, Many icons, No transient prompt

## Initial environment modifications (further manual edits to ~/.bashrc will be required later)
mkdir ~/.bashrc.d ~/scripts
fd -E '*yubikey.sh' . ../bash_kittyterm/bashrc.d/ -X cp {} ~/.bashrc.d
cp ../bash_kittyterm/xdg-base-setup.sh ~/scripts
source "$HOME/.bashrc"
source "$HOME/scripts/xdg-base-setup.sh"

# "Languages" - Java, C/C++, Perl, system Python, PHP, OpenSSL, SQLite
sudo dnf -y install java-latest-openjdk-devel maven cmake meson binutils libtool gcc \
    gcc-c++ clang-devel perl-devel python3-devel openssl-devel composer sqlite3
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh # Requires manual intervention

## Languages - Rust
# shellcheck disable=SC2016
mv ~/.cargo ~/.local/share/cargo && sed -i 's/$HOME\/.cargo/$CARGO_HOME/' ~/.local/share/cargo/env
. "$CARGO_HOME/env"
cp ../rust/config.toml "$CARGO_HOME"/config.toml
rustup toolchain install nightly
rustup component add rust-src rust-analyzer
rustup component add --toolchain nightly miri rust-src rust-analyzer

## Languages - NodeJS
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
source "$HOME/.bashrc"
nvm install node

## Languages - user Python and packages
curl -LsSf https://astral.sh/uv/install.sh | bash
source "$HOME/.bashrc"
sudo dnf -y install python3-{requests,beautifulsoup4,gobject} # Used by the localrepos, but want to fix this at some poiont
pip install --no-input selenium webdriver_manager

## Languages - The most sane way to setup Ruby on Fedora
sudo dnf -y install gcc patch make bzip2 openssl-devel libyaml-devel libffi-devel readline-devel zlib-devel gdbm-devel ncurses-devel perl-FindBin perl-File-Compare
curl -fsSL https://github.com/rbenv/rbenv-installer/raw/HEAD/bin/rbenv-installer | bash

## Languages - TypeScript
npm install typescript

## Languages - Objectively the shittiest installation method belongs to Go. It doesn't get
## to use the latest version because of it
curl -fsSL -o go1.23.2.linux-amd64.tar.gz https://go.dev/dl/go1.23.2.linux-amd64.tar.gz
sudo rm -rf /usr/local/go && sudo tar -C /usr/local -xzf go1.23.2.linux-amd64.tar.gz
rm go1.23.2.linux-amd64.tar.gz
source "$HOME/.bashrc"

# PlatformIO Core
curl -fsSL -o get-platformio.py https://raw.githubusercontent.com/platformio/platformio-core-installer/master/get-platformio.py
python3 get-platformio.py && rm get-platformio.py
for pbin in pio platformio piodebuggdb; do ln -s "$HOME/.platformio/penv/bin/$pbin" "$HOME/.local/bin/$pbin"; done
curl -fsSL https://raw.githubusercontent.com/platformio/platformio-core/develop/platformio/assets/system/99-platformio-udev.rules | sudo tee /etc/udev/rules.d/99-platformio-udev.rules
sudo udevadm control -R && sudo udevadm trigger

# Kernel dev
sudo dnf install kernel-devel fedpkg fedora-packager ncurses-devel pesign grubby
sudo dnf builddep kernel kernel-devel

# Flatpaks, RPMs, and app packaging
sudo dnf -y install flatpak-builder
sudo dnf -y group install 'RPM Development Tools'

# Container stuff
sudo dnf -y install podman podman-compose buildah skopeo

# Disable gnome-keyring-ssh (thanks https://askubuntu.com/a/607563 and https://askubuntu.com/a/585212)
mkdir -p ~/.config/autostart
(cat /etc/xdg/autostart/gnome-keyring-ssh.desktop; echo Hidden=true) > ~/.config/autostart/gnome-keyring-ssh.desktop

# Google Chrome
sudo dnf -y config-manager --set-enabled google-chrome
sudo dnf makecache
sudo dnf -y install google-chrome-stable

# VS Code https://code.visualstudio.com/docs/setup/linux
sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
sudo sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo'
sudo dnf makecache
sudo dnf -y install code

# PowerShell
curl https://packages.microsoft.com/config/rhel/8/prod.repo | sudo tee /etc/yum.repos.d/microsoft-rhel8.repo
sudo sed -i 's/name=.*$/name=microsoft-prod-rhel8/' /etc/yum.repos.d/microsoft-rhel8.repo
sudo sed -i 's/\[packages.*\]$/[microsoft-prod-rhel8]/' /etc/yum.repos.d/microsoft-rhel8.repo
curl https://packages.microsoft.com/config/rhel/9/prod.repo | sudo tee /etc/yum.repos.d/microsoft-rhel9.repo
sudo sed -i 's/name=.*$/name=microsoft-prod-rhel9/' /etc/yum.repos.d/microsoft-rhel9.repo
sudo sed -i 's/\[packages.*\]$/[microsoft-prod-rhel9]/' /etc/yum.repos.d/microsoft-rhel9.repo
sudo dnf makecache
sudo dnf -y install powershell

# 1Password Beta https://support.1password.com/betas
sudo rpm --import https://downloads.1password.com/linux/keys/1password.asc
sudo sh -c 'echo -e "[1password]\nname=1Password Beta Channel\nbaseurl=https://downloads.1password.com/linux/rpm/beta/\$basearch\nenabled=1\ngpgcheck=1\nrepo_gpgcheck=1\ngpgkey=\"https://downloads.1password.com/linux/keys/1password.asc\"" > /etc/yum.repos.d/1password.repo'
sudo dnf makecache
sudo dnf -y install 1password 1password-cli

# NVIDIA Container Toolkit https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/install-guide.html
curl -s -L https://nvidia.github.io/libnvidia-container/rhel9.0/libnvidia-container.repo | sudo tee /etc/yum.repos.d/nvidia-container-toolkit.repo # As of November 2022
unset distribution
sudo dnf makecache
sudo dnf -y install nvidia-container-toolkit
sudo sed -i 's/^#no-cgroups = false/no-cgroups = true/;' /etc/nvidia-container-runtime/config.toml # rootless

# YubiKey Manager, Personalization Tool, Authenticator, PAM
sudo dnf -y install yubikey-personalization-gui pam_yubico pam-u2f pamu2fcfg yubikey-manager
wget -O yubico-authenticator-latest-linux.tar.gz https://developers.yubico.com/yubioath-flutter/Releases/yubico-authenticator-latest-linux.tar.gz  && tar -xzf yubico-authenticator-latest-linux.tar.gz && rm -f yubico-authenticator-latest-linux.tar.gz
if mv "$(find . -maxdepth 1 -regex '.*yubico.*')" ~/.config; then
  find "$HOME"/.config -maxdepth 1 -regex '.*yubico-auth.*' -exec bash -c 'ln -s $(realpath $1) ~/.config/yubiauth' -- {} \;
fi
chmod +x ~/.config/yubiauth/desktop_integration.sh && bash -c "$HOME/.config/yubiauth/desktop_integration.sh -i"

# Other tools
sudo dnf -y install gh dconf-editor nmap xeyes colordiff fzf setroubleshoot setools-console \
  policycoreutils-devel 'dnf-command(versionlock)' shellcheck sysstat jq wl-clipboard

# Environment setup
if [[ $(stty size | awk '{print $2}') -ge 256 ]]; then # Larger TTY font for 4K displays
    sudo cp ./ttyfont.sh /etc/profile.d/ttyfont.sh
fi

uv tool install git+ssh://git@github.com/powerline/powerline.git@develop # pip is out of date, see powerline#2116
uv tool install yq
sudo dnf -y install jetbrains-mono-fonts-all linux-libertine-biolinum-fonts kitty neofetch powerline-fonts
gsettings set org.gnome.nautilus.preferences show-hidden-files true
gsettings set org.gtk.gtk4.Settings.FileChooser show-hidden true

curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

mkdir -p "$XDG_CONFIG_HOME"/tmux/plugins
git clone git@github.com:tmux-plugins/tpm.git "$XDG_CONFIG_HOME"/tmux/plugins/tpm

gsettings set org.gnome.desktop.default-applications.terminal exec kitty
mkdir -p ~/.config/kitty/kitty.d
cat <<EOF > ~/.config/kitty/kitty.conf
globinclude kitty.d/**/*.conf
EOF
cp ../bash_kittyterm/click.oga ../bash_kittyterm/kitty-custom.conf ~/.config/kitty/kitty.d/
kitty +kitten themes --reload-in=all Catppuccin-Macchiato

mkdir ~/develop # Root level folder for all coding stuff
mkdir ~/.config/procps
cp ../scripts/colocat.py ../scripts/git-unsync ../scripts/pgpcard-reload ../scripts/doi-handler/doi-handler ~/scripts
cp ../bash_kittyterm/toprc ~/.config/procps/toprc
cp ../scripts/doi-handler/doi-handler.desktop "$XDG_DATA_HOME"/applications/
xdg-mime default doi-handler.desktop x-scheme-handler/doi

# Manually installed to /opt as needed: JetBrains Toolbox & Co.
