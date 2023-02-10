#!/bin/bash
# Setting up GNOME Terminal for Nord theme

pushd ~/Downloads
git clone https://github.com/arcticicestudio/nord-gnome-terminal.git
pushd nord-gnome-terminal/src
./nord.sh
popd
rm -rf ./nord-gnome-terminal
popd

### Manually change default theme ###

# Powerline (https://www.reddit.com/r/powerline/comments/3o1qlf/tips_and_tricks_trim_directory_names_for_long/)
mkdir -p ~/.config/powerline
cp -r ../powerline_cfg ~/.config/powerline

