echo "Installing APT-Proxies"
echo 'Acquire::http::Proxy-Auto-Detect "/usr/local/bin/apt-proxy-detect.sh";' > /etc/apt/apt.conf.d/00aptproxy
echo -e '#!/bin/bash\nif nc -w1 -z "10.0.1.5" 3142; then\n  echo -n "http://10.0.1.5:3142"\nelif nc -w1 -z "10.0.1.6" 3142; then\n  echo -n "http://10.0.1.6:3142"\nelse\n  echo -n "DIRECT"\nfi' > /usr/local/bin/apt-proxy-detect.sh
chmod +x /usr/local/bin/apt-proxy-detect.sh
echo "Installed APT Proxies"

echo "Installing APT Packages"
apt update && apt upgrade -y
apt install make git tmux gpg -y
echo "Installed APT Packages"

echo "Installing Neovim"
curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz
rm -rf /opt/nvim
tar -C /opt -xzf nvim-linux-x86_64.tar.gz
echo "export PATH='$PATH:/opt/nvim-linux-x86_64/bin'" >> ~/.bashrc
sudo rm nvim-linux-x86_64.tar.gz
echo "Installed Neovim"

echo "Configuring Neovim"
git clone --depth 1 https://github.com/AstroNvim/template ~/.config/nvim
rm -rf ~/.config/nvim/.git
echo "Configured Neovim"

echo "Installing Sexy Bash"
(cd /tmp && ([[ -d sexy-bash-prompt ]] || git clone --depth 1 --config core.autocrlf=false https://github.com/twolfson/sexy-bash-prompt) && cd sexy-bash-prompt && make install) && source ~/.bashrc
echo "Installed Sexy Bash"

echo "Setting up tmux"
echo '' >> ~/.bashrc
echo '# Automatically create or attach to a tmux session named after the hostname' >> ~/.bashrc
echo '# Check if running interactively, not already in tmux, and tmux command exists' >> ~/.bashrc
echo 'if [[ "$-" == *i* ]] && [[ -z "$TMUX" ]] && command -v tmux &> /dev/null; then' >> ~/.bashrc
echo '    # Get the short hostname (e.g., '\''my-server'\'' instead of '\''my-server.example.com'\'')' >> ~/.bashrc
echo '    TMUX_SESSION_NAME=$(hostname -s)' >> ~/.bashrc
echo '' >> ~/.bashrc
echo '    # Check if the session already exists' >> ~/.bashrc
echo '    if tmux has-session -t "$TMUX_SESSION_NAME" 2>/dev/null; then' >> ~/.bashrc
echo '        # Session exists, attach to it' >> ~/.bashrc
echo '        echo "Attaching to existing tmux session: $TMUX_SESSION_NAME"' >> ~/.bashrc
echo '        tmux attach-session -t "$TMUX_SESSION_NAME"' >> ~/.bashrc
echo '    else' >> ~/.bashrc
echo '        # Session does not exist, create it' >> ~/.bashrc
echo '        echo "Creating new tmux session: $TMUX_SESSION_NAME"' >> ~/.bashrc
echo '        tmux new-session -s "$TMUX_SESSION_NAME"' >> ~/.bashrc
echo '    fi' >> ~/.bashrc
echo 'fi' >> ~/.bashrc
echo "Tmux configured"
