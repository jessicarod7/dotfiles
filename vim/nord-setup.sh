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

# Powerline
sudo dnf install powerline powerline-fonts
mkdir -p $POWERLINE/themes/shell
# https://eshlox.net/2017/08/10/how-to-install-powerline-for-bash-on-fedora-with-git-branch-support
cat <<EOF > $POWERLINE/config.json
{
    "ext": {
        "shell": {
            "theme": "default_leftonly"
        }
    },
    "term_truecolor": true
}
EOF

# https://www.reddit.com/r/powerline/comments/3o1qlf/tips_and_tricks_trim_directory_names_for_long/
cat <<EOF > $POWERLINE/themes/shell/default_leftonly.json
{
	"args": {
		"dir_shorten_len": 20
	}
}
EOF

powerline-daemon --replace
