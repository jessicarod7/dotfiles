# Not a full bashrc, just additions

### "User specific environment" block

# General exports need to run first
. "$HOME"/scripts/xdg-base-setup.sh

### "User specific aliases and functions" block

# Exit if not an interactive shell
[ -z "$PS1" ] && return

# Powerline
export POWERLINE=~/.config/powerline
if [[ ! -e $(which powerline-daemon) ]]; then
	powerline-daemon -q
	# shellcheck disable=SC2034
	POWERLINE_BASH_CONTINUATION=1
	# shellcheck disable=SC2034
	POWERLINE_BASH_SELECT=1
	. "$HOME"/.local/lib/python3.11/site-packages/powerline/bindings/bash/powerline.sh
fi

# Neofetch
neofetch  --title_fqdn on --distro_shorthand on --refresh_rate on --gtk2 off --gtk3 off \
--memory_percent on --disable packages # --gpu_type dedicated
### [ EOF ]
