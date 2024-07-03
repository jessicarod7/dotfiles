# Not a full bashrc, just additions

### "User specific environment" block

# General exports need to run first
. "$HOME"/scripts/xdg-base-setup.sh

### "User specific aliases and functions" block

# Exit if not an interactive shell
[ -z "$PS1" ] && return

# Powerline
POWERLINE_REPO_ROOT=$(fd -at d site-packages "$XDG_DATA_HOME/uv/tools/powerline-status")
export POWERLINE_REPO_ROOT
if [[ -e $(which powerline-daemon) ]] && [[ -n "$POWERLINE_REPO_ROOT" ]]; then
  export POWERLINE="$HOME/.config/powerline"
	powerline-daemon -q
	# shellcheck disable=SC2034
	POWERLINE_BASH_CONTINUATION=1
	# shellcheck disable=SC2034
	POWERLINE_BASH_SELECT=1
	. "$POWERLINE_REPO_ROOT/powerline/bindings/bash/powerline.sh"
fi

# Neofetch
neofetch  --title_fqdn on --distro_shorthand on --refresh_rate on --gtk2 off --gtk3 off \
--memory_percent on --disable packages # --gpu_type dedicated
### [ EOF ]
