# Jessica's Dotfiles

Various configurations and customizations I like to use on my machines.

I haven't put much work into making this easy to setup. Despite the appearance of reasonably organized Bash scripts,
I've never actually executed them; I just copy-paste and fix them as I go. No guarantees are made, but here's how I
usually go about setup:

1. Configure [Git](./git) and [SSH](./ssh) (sometimes [GPG](./gpg)), then clone this repo locally.
2. It's helpful to configure the files in [`bash_kittyterm/`](./bash_kittyterm) around this point, copy-pasting into the 
   relevant files. [`.bashrc`](./bash_kittyterm/.bashrc) and [`bashrc.d/`](./bash_kittyterm/bashrc.d) in particular are good
   to set up early. 
3. Start with [`devtools.sh`](./linux_pkgs/devtools.sh), then [`apps.sh`](./linux_pkgs/apps.sh). Along the way, config the
   rest of the earlier directories, and load in configs for:
    - [KWrite](./kwrite)
    - [Powerline](./powerline_cfg)
    - [Qalculate](./qalculate)
    - [relevant scripts](./scripts)
    - [systemd units](./systemd)
    - [tmux](./tmux)
    - [Vim](./vim)

The remaining directories are meant to be copied in or used as needed.

## My style

<img alt="Screenshot of my Fedora desktop, featuring IntelliJ and kitty. IntelliJ, with the Catpuccin Macchiato theme, is opened to gpg_op_passphrase. kitty, with the Nord theme, shows neofetch." style="max-width: 100%; height: auto; display: block; margin: 0px auto;" src=./assets/theme.png><br>

- Core editors: [IntelliJ IDEA](https://www.jetbrains.com/)[^1] + [KWrite](https://apps.kde.org/kwrite/) + [Vim](https://www.vim.org/)
- Notes and journalling: [Obsidian](https://obsidian.md/)
- OS/DE: [Fedora Workstation](https://fedoraproject.org/workstation/) with [GNOME](https://www.gnome.org/)
- Terminal: [kitty](https://sw.kovidgoyal.net/kitty/) + [fish](https://github.com/IlanCosman/tide) (fallback to [Bash](https://www.gnu.org/software/bash/))
- Themes: [Nord](https://www.nordtheme.com/) + [Catppuccin's Macchiato flavour](https://catppuccin.com/)
    - Enhancements: [tide](https://github.com/IlanCosman/tide) (fish), [vim-airline](https://github.com/vim-airline/vim-airline) (Vim), [Powerline](https://github.com/powerline/powerline) (Bash)
- Font: [JetBrains Mono](https://www.jetbrains.com/lp/mono/)

## Repo Notes

- Files are sorted by program or related topics
- Commented out lines are intended for Windows systems unless otherwise stated
- Linux commands assume Fedora distro
- (Personal) Set `gpg.program` for this repo to [`gpg_op_passphrase`](./scripts/gpg_op_passphrase)

[^1]: With _all_ of the extensions. For those few times I'm writing C/C++, I use CLion.