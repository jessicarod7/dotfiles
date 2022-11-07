#!/bin/bash

# Java, C/C++, NodeJS, Perl
sudo dnf install java-latest-openjdk-devel cmake meson autoconf automake libgcc.x86_64 libgcc.i686 \
    glibc-devel.x86_64 glibc-devel.i686 gcc-c++.x86_64 gcc-c++.i686 clang nodejs perl

# VS Code
sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
sudo sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo'
sudo dnf check-update
sudo dnf install code

# Environment setup
sudo dnf install kitty fira-code-fonts neofetch gh dconf-editor
gsettings set org.gnome.nautilus.preferences show-hidden-files true
gsettings set org.gtk.gtk4.settings.file-chooser show-hidden true

gsettings set org.gnome.settings.default-applications.terminal exec kitty
mkdir -p ~/.config/kitty/kitty.d
curl -o ~/.config/kitty/kitty.d/nord.conf https://raw.githubusercontent.com/connorholyday/nord-kitty/master/nord.conf
echo -e '\n\nglobinclude kitty.d/**/.conf' >> ~/.config/kitty/kitty.conf

mkdir ~/develop # Root level folder for all coding stuff
mkdir ~/scripts # Added to PATH

# Manually installed to /opt: STM32CubeIDE, arm-none-eabi