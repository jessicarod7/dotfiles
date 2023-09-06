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

### Manually change default theme ###

# Powerline (https://www.reddit.com/r/powerline/comments/3o1qlf/tips_and_tricks_trim_directory_names_for_long/)
mkdir -p ~/.config/powerline
cp -r ../powerline_cfg ~/.config/powerline

