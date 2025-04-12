#!/bin/bash

# Define current script version
SCRIPT_VERSION=1

# Get the installed version (default to 0 if not set)
INSTALLED_VERSION="${NEOVIM_INSTALLER_VERSION:-0}"

# Define unique markers for the block in .bashrc
MARKER_BEGIN="# >>> NEOVIM_INSTALLER_BEGIN"
MARKER_END="# <<< NEOVIM_INSTALLER_END"

# Function to install Neovim
install_neovim() {
  echo "🔧 Installing Neovim (Version: $SCRIPT_VERSION)..."

  # Download Neovim tarball
  curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz

  # Remove any existing install
  sudo rm -rf /opt/nvim /opt/nvim-linux-x86_64

  # Extract Neovim to /opt
  sudo tar -C /opt -xzf nvim-linux-x86_64.tar.gz

  # Create a stable symlink
  sudo ln -s /opt/nvim-linux-x86_64 /opt/nvim

  # Clean up the downloaded tarball
  rm nvim-linux-x86_64.tar.gz

  # Add to PATH if not already in .bashrc
  sed -i "/$MARKER_BEGIN/,/$MARKER_END/d" ~/.bashrc  # Remove any existing Neovim marker block
  cat <<EOF >> ~/.bashrc
$MARKER_BEGIN
# Neovim installation - Added by Neovim installer
export PATH="\$PATH:/opt/nvim/bin"
$MARKER_END
EOF

  echo "📎 Updated PATH in ~/.bashrc"

  echo "✅ Neovim installed at /opt/nvim"

  export NEOVIM_INSTALLER_VERSION="$SCRIPT_VERSION"
}

# Function to uninstall Neovim
uninstall_neovim() {
  echo "🧹 Uninstalling Neovim (Version: $INSTALLED_VERSION)..."

  # Remove binaries and symlink
  sudo rm -rf /opt/nvim /opt/nvim-linux-x86_64

  # Remove Neovim PATH line from .bashrc
  sed -i "/$MARKER_BEGIN/,/$MARKER_END/d" ~/.bashrc

  # Optionally remove config (ask to confirm)
  read -rp "Do you want to delete your Neovim config at ~/.config/nvim? [y/N] " confirm
  if [[ "$confirm" =~ ^[Yy]$ ]]; then
    rm -rf ~/.config/nvim
    echo "🗑️  Neovim config removed"
  else
    echo "⚠️  Skipped config removal"
  fi

  echo "✅ Neovim uninstalled"
  unset NEOVIM_INSTALLER_VERSION
}

# Function to configure Neovim (AstroNvim)
configure_neovim() {
  echo "🎨 Configuring AstroNvim..."
  rm -rf ~/.config/nvim
  git clone --depth 1 https://github.com/AstroNvim/template ~/.config/nvim
  rm -rf ~/.config/nvim/.git
  echo "✅ AstroNvim template installed"
}

# Main logic
if [[ "$SCRIPT_VERSION" -gt "$INSTALLED_VERSION" ]]; then
  if [[ "$INSTALLED_VERSION" -gt 0 ]]; then
    uninstall_neovim
  fi
  install_neovim
  configure_neovim
elif [[ "$SCRIPT_VERSION" -eq "$INSTALLED_VERSION" ]]; then
  echo "✅ Neovim is already up-to-date (Version: $INSTALLED_VERSION)"
fi
