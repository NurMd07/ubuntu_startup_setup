#!/bin/bash

# store user password
read -s -p "Password: " SUDOPASS

# helper func to pass stored password
sudo_pass() {
    echo "$SUDOPASS" | sudo -S "$@"
}

# exit if any error
set -e

# updating and installing required packages
sudo_pass apt-get update -y
sudo_pass apt install zsh git curl unzip lsd -y

ohmyzsh_install(){
    if [ -d "$HOME/.oh-my-zsh" ]; then
        echo "⚡ Oh My Zsh already installed, skipping..."
    else
        echo "⚡ Installing Oh My Zsh..."
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    fi
}


zinit_install() {
	 if [ -d "$HOME/.local/share/zinit" ]; then
        echo "⚡ zinit already installed, skipping..."
    else
    	echo "⚡ Installing Zinit (non-interactive)..."
   		mkdir -p "$HOME/.local/share/zinit"
    	if [ ! -d "$HOME/.local/share/zinit/zinit.git" ]; then
        	git clone https://github.com/zdharma-continuum/zinit.git "$HOME/.local/share/zinit/zinit.git"
    	fi
    fi
}

zshrc_setup(){
	# plugins and theme config to .zshrc
	cat << 'EOF' >> "$HOME/.zshrc"
source "$HOME/.local/share/zinit/zinit.git/zinit.zsh"

# zsh-completions init
autoload -U compinit && compinit

# Plugins
zinit light zsh-users/zsh-autosuggestions
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions
zinit light marlonrichert/zsh-autocomplete

# Load boxy theme
source "$HOME/.zsh-themes/td.zsh-theme"

# Clear screen and run fastfetch with Ubuntu logo
clear
echo ""
fastfetch --logo $HOME/.config/fastfetch/ubuntu_logo.txt

# Useful alias with lsd
alias ls='lsd --group-dirs=first --icon=always --color=always'
alias ll='lsd -l'
alias la='lsd -a'
alias lla='lsd -la'
EOF

	# zinit self-update once
	echo "⚡ Running zinit self-update..."
	zsh -i -c 'zinit self-update || true'

}

fastfetch_setup(){

	arch=$(dpkg --print-architecture)  
	# get competible fastfetch package .deb
	latest_url=$(curl -sL https://api.github.com/repos/fastfetch-cli/fastfetch/releases/latest \
	| grep "browser_download_url.*deb" \
	| grep "$arch" \
	| cut -d '"' -f 4)

	echo "Downloading Fastfetch from: $latest_url"

	curl -L "$latest_url" -o /tmp/fastfetch.deb
	sudo_pass dpkg -i /tmp/fastfetch.deb || sudo_pass apt-get install -f -y
	rm /tmp/fastfetch.deb

	echo "✅ Fastfetch installed!"
}

configs_setup(){
	
	mkdir -p $HOME/.zsh-themes
	mkdir -p $HOME/.config/fastfetch

	cp ./config.jsonc $HOME/.config/fastfetch/config.jsonc
	cp ./ubuntu_logo.txt $HOME/.config/fastfetch/ubuntu_logo.txt
	cp ./td.zsh-theme $HOME/.zsh-themes/td.zsh-theme

	sed -i 's/\r$//' ~/.zsh-themes/td.zsh-theme

}

install_nerdfonts(){
    echo "⚡ Installing Nerd Fonts..."
    
    FONT_NAME="FiraCode"
    FONT_DIR="$HOME/.local/share/fonts"

    mkdir -p "$FONT_DIR"

    FONT_ZIP=$(mktemp)
    curl -sLo "$FONT_ZIP" "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/${FONT_NAME}.zip"

    unzip -o "$FONT_ZIP" -d "$FONT_DIR" >/dev/null
    rm "$FONT_ZIP"

    if command -v fc-cache >/dev/null 2>&1; then
        fc-cache -fv "$FONT_DIR" >/dev/null
    fi

    echo "✅ Nerd Fonts installed!"
}


sudo_pass chsh -s "$(command -v zsh)" "$USER"


ohmyzsh_install
zinit_install
zshrc_setup
fastfetch_setup
configs_setup
install_nerdfonts

echo "✅ Installation complete. Restart your session or run: exec zsh"
