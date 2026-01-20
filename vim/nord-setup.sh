#!/bin/bash
# Setting up GNOME Terminal for Nord theme
# On Windows, use https://github.com/thismat/nord-windows-terminal

pushd ~/Downloads
git clone https://github.com/nordtheme/gnome-terminal.git nord-gnome-terminal
pushd nord-gnome-terminal/src
./nord.sh
popd
rm -rf ./nord-gnome-terminal
popd
