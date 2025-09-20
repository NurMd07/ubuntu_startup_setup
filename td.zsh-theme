# td.zsh-theme - A clean and functional ZSH theme with distro detection
# Created for Termux and proot-distro environments

autoload -Uz colors && colors
autoload -Uz vcs_info
setopt complete_aliases

# Enable Git branch display
zstyle ':vcs_info:git:*' formats ' %F{magenta} %b%f'
precmd() { vcs_info }
setopt PROMPT_SUBST

# Exit status indicator
exit_status="%(?..%F{red}✘ %?%f)"

# Detect distro and set the correct icons
if command -v grep &> /dev/null && [ -f /etc/os-release ]; then
    distro_id=$(grep '^ID=' /etc/os-release 2>/dev/null | cut -d= -f2 | tr -d '"') 2>/dev/null
else
    distro_id="unknown"
fi

case "$distro_id" in
  kali) DISTRO_ICON="" ;;   # Kali Linux
  arch) DISTRO_ICON="" ;;   # Arch Linux
  ubuntu) DISTRO_ICON="" ;; # Ubuntu
  debian) DISTRO_ICON="" ;; # Debian
  fedora) DISTRO_ICON="" ;; # Fedora
  alpine) DISTRO_ICON="" ;; # Alpine
  void) DISTRO_ICON="" ;;   # Void Linux
  opensuse*|sles) DISTRO_ICON="" ;; # openSUSE
  gentoo) DISTRO_ICON="" ;; # Gentoo
  nixos) DISTRO_ICON="" ;; # NixOS
  *) DISTRO_ICON=" " ;;      # Default Linux Icon
esac

# Symbols
PROMPT_SYMBOL="%F{green}❯%F{reset}"

# Check if running in Termux and set username accordingly
if [[ -n "$PREFIX" && "$PREFIX" == */com.termux/* ]]; then
    user_name="nurmd"
else
    user_name="$(whoami)"
fi

# User and host info inside a box with DISTRO_ICON in the middle
user_host="%F{blue}[%F{cyan}$user_name%F{yellow} $DISTRO_ICON %F{cyan}%m%F{blue}]%f"

# Current directory inside the same box
dir_display="%F{blue}[%F{yellow}%~%F{blue}]%f"

# Prompt layout (P10K-like)
PROMPT='
%B%F{green}╭─ $user_host $dir_display${vcs_info_msg_0_}
%B%F{green}╰─${PROMPT_SYMBOL} %F{reset}'

# Right prompt shows exit status of previous command
RPROMPT="$exit_status"