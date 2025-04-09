echo "Installing APT-Proxies"
echo 'Acquire::http::Proxy-Auto-Detect "/usr/local/bin/apt-proxy-detect.sh";' > /etc/apt/apt.conf.d/00aptproxy
echo -e '#!/bin/bash\nif nc -w1 -z "10.0.1.5" 3142; then\n  echo -n "http://10.0.1.5:3142"\nelif nc -w1 -z "10.0.1.6" 3142; then\n  echo -n "http://10.0.1.6:3142"\nelse\n  echo -n "DIRECT"\nfi' > /usr/local/bin/apt-proxy-detect.sh
chmod +x /usr/local/bin/apt-proxy-detect.sh
echo "Installed APT Proxies"
echo "Installing APT Packages"
apt install git -y
apt install make -y
apt install snapd -y
echo "Installing Neovim"
snap install nvim --edge --classic
echo "alias nvim='snap run nvim'" >> ~/.bashrc
echo "Installed Neovim"

