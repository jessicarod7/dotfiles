#!/bin/bash
# Run from this directory

# RPM Fusion, other nonfree libraries
sudo dnf install https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
sudo dnf install fedora-workstation-repositories

# Java, C/C++, NodeJS, Perl
sudo dnf install java-latest-openjdk-devel cmake meson binutils libtool glibc-devel \
    gcc-c++ clang nodejs npm perl

# Useful Python packages
sudo dnf install poetry python3-{requests,beautifulsoup4,gobject}

# VS Code https://code.visualstudio.com/docs/setup/linux
sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
sudo sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo'
sudo dnf check-update
sudo dnf install code

# 1Password Beta https://support.1password.com/betas
sudo rpm --import https://downloads.1password.com/linux/keys/1password.asc
sudo sudo sh -c 'echo -e "[1password-beta]\nname=1Password Beta Channel\nbaseurl=https://downloads.1password.com/linux/rpm/beta/\$basearch\nenabled=1\ngpgcheck=1\nrepo_gpgcheck=1\ngpgkey=\"https://downloads.1password.com/linux/keys/1password.asc\"" > /etc/yum.repos.d/1password-beta.repo'
sudo dnf check-update
sudo dnf install 1password 1password-cli

# NVIDIA Container Toolkit https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/install-guide.html
curl -s -L https://nvidia.github.io/libnvidia-container/rhel9.0/libnvidia-container.repo | sudo tee /etc/yum.repos.d/nvidia-container-toolkit.repo # As of November 2022
unset distribution
sudo dnf check-update
sudo dnf install nvidia-container-toolkit
sudo sed -i 's/^#no-cgroups = false/no-cgroups = true/;' /etc/nvidia-container-runtime/config.toml # rootless

# Other tools
sudo dnf gh dconf-editor screen podman buildah skopeo

# Environment setup
pip install git+ssh://git@github.com/powerline/powerline.git@develop # pip is out of date, see powerline#2116
sudo dnf install vim-enhanced fira-code-fonts kitty neofetch powerline-fonts
gsettings set org.gnome.nautilus.preferences show-hidden-files true
gsettings set org.gtk.gtk4.Settings.FileChooser show-hidden true

cp -r ../powerline_cfg ~/.config/powerline
curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

gsettings set org.gnome.desktop.default-applications.terminal exec kitty
mkdir -p ~/.config/kitty/kitty.d
curl -o ~/.config/kitty/kitty.d/nord.conf https://raw.githubusercontent.com/connorholyday/nord-kitty/master/nord.conf
cat <<EOF > ~/.config/kitty/kitty.conf
globinclude kitty.d/**/*.conf
EOF
cp ../bash_kittyterm/click.oga ../bash_kittyterm/kitty-custom.conf ~/.config/kitty/kitty.d/

mkdir ~/develop # Root level folder for all coding stuff
mkdir ~/scripts # Added to PATH
cp ./dev_scripts/colocat.py ~/scripts
cp ../dev_scripts/git-unsync.py ~/scripts

# Manually installed to /opt as needed: IntelliJ Community Edition, STM32CubeIDE, arm-none-eabi
