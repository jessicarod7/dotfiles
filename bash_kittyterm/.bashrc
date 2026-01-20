# Not a full bashrc, just additions

### "User specific environment" block

# General exports need to run first
. "$HOME"/scripts/xdg-base-setup.sh

### "User specific aliases and functions" block

# Exit if not an interactive shell
[ -z "$PS1" ] && return

# Hyfetch
hyfetch
### [ EOF ]
