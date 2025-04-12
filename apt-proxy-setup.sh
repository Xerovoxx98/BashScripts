#!/bin/bash

# Define the current script version (integer)
SCRIPT_VERSION=2

# Check if the environment variable exists and get the installed version
INSTALLED_VERSION="${APT_PROXY_INSTALLER_VERSION:-0}" # default to 0 if not set.

# Function to install the APT proxies
install_apt_proxies() {
  echo "Installing APT-Proxies (Version: $SCRIPT_VERSION)"
  echo 'Acquire::http::Proxy-Auto-Detect "/usr/local/bin/apt-proxy-detect.sh";' > /etc/apt/apt.conf.d/00aptproxy
  echo -e '#!/bin/bash\nif nc -w1 -z "10.0.1.5" 3142; then\n  echo -n "http://10.0.1.5:3142"\nelif nc -w1 -z "10.0.1.6" 3142; then\n  echo -n "http://10.0.1.6:3142"\nelse\n  echo -n "DIRECT"\nfi' > /usr/local/bin/apt-proxy-detect.sh
  chmod +x /usr/local/bin/apt-proxy-detect.sh
  echo "Installed APT Proxies (Version: $SCRIPT_VERSION)"
  export APT_PROXY_INSTALLER_VERSION="$SCRIPT_VERSION"
}

# Function to uninstall the APT proxies
uninstall_apt_proxies() {
  echo "Uninstalling APT-Proxies (Version: $INSTALLED_VERSION)"
  rm -f /etc/apt/apt.conf.d/00aptproxy
  rm -f /usr/local/bin/apt-proxy-detect.sh
  echo "Uninstalled APT Proxies (Version: $INSTALLED_VERSION)"
  unset APT_PROXY_INSTALLER_VERSION
}

# Compare versions and perform actions
if [[ "$SCRIPT_VERSION" -gt "$INSTALLED_VERSION" ]]; then
  if [[ -n "$INSTALLED_VERSION" ]] && [[ "$INSTALLED_VERSION" -gt 0 ]]; then
    uninstall_apt_proxies
  fi
  install_apt_proxies
elif [[ "$SCRIPT_VERSION" -eq "$INSTALLED_VERSION" ]]; then
  echo "APT-Proxies are up-to-date (Version: $INSTALLED_VERSION)"
fi