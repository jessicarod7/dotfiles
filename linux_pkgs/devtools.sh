#!/bin/bash

# Java, C/C++, NodeJS
sudo dnf install java-latest-openjdk-devel cmake meson autoconf automake libgcc.x86_64 libgcc.i686 \
    glibc-devel.x86_64 glibc-devel.i686 gcc-c++.x86_64 gcc-c++.i686 clang nodejs

# VS Code
sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
sudo sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo'
sudo dnf check-update
sudo dnf install code

# Environment setup
sudo dnf install fira-code-fonts neofetch gh
mkdir ~/develop # Root level folder for all coding stuff
mkdir ~/scripts # Added to PATH

# Manually installed to /opt: STM32CubeIDE, arm-none-eabi