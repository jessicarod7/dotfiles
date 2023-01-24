# System Auth Notes

For working with PAM.

- **Basics**
  - Four main types: `account` (non-auth acct. management, like expired password, authorized user?), `auth`entication (login), `password` (specifically to update credentials), `session` (pre-/post-session management)
  - Second field is return code: `required`, `requisite` (fail-fast, don't follow the rest of the stack), `sufficient`, `optional`, `include` (another config file), `substack` (treat as an internal stack)
  - Last field is module + options.
- **Files** in `/etc/pam.d`
  - `sudo` manages sudo, `passwd` for passwd, and so on
  - notably, `gdm-password` manages GNOME's login, and `polkit-1` manages Polkit popups
