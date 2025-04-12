#!/bin/bash

# Install Dependancies
apt install make git tmux gpg gcc -y
curl -sSL https://raw.githubusercontent.com/Xerovoxx98/BashScripts/refs/heads/main/apt-proxy-setup.sh | bash
curl -sSL https://raw.githubusercontent.com/Xerovoxx98/BashScripts/refs/heads/main/astro-neovim-setup.sh | bash
curl -sSL https://raw.githubusercontent.com/Xerovoxx98/BashScripts/refs/heads/main/sexy-bash-setup.sh | bash
curl -sSL https://raw.githubusercontent.com/Xerovoxx98/BashScripts/refs/heads/main/tmux-auto-setup.sh | bash