echo "Installing APT-Proxies"
echo 'Acquire::http::Proxy-Auto-Detect "/usr/local/bin/apt-proxy-detect.sh";' > /etc/apt/apt.conf.d/00aptproxy
echo -e '#!/bin/bash\nif nc -w1 -z "10.0.1.5" 3142; then\n  echo -n "http://10.0.1.5:3142"\nelif nc -w1 -z "10.0.1.6" 3142; then\n  echo -n "http://10.0.1.6:3142"\nelse\n  echo -n "DIRECT"\nfi' > /usr/local/bin/apt-proxy-detect.sh
chmod +x /usr/local/bin/apt-proxy-detect.sh
echo "Installed APT Proxies"
echo "Installing APT Packages"
apt install make -y
echo "Installing Neovim"
curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz
sudo rm -rf /opt/nvim
sudo tar -C /opt -xzf nvim-linux-x86_64.tar.gz
echo "export PATH='$PATH:/opt/nvim-linux-x86_64/bin'" >> ~/.bashrc
sudo rm nvim-linux-x86_64.tar.gz
echo "Installed Neovim"
echo "Installing Sexy Bash"
(cd /tmp && ([[ -d sexy-bash-prompt ]] || git clone --depth 1 --config core.autocrlf=false https://github.com/twolfson/sexy-bash-prompt) && cd sexy-bash-prompt && make install) && source ~/.bashrc
echo "Installed Sexy Bash"
