#!/bin/bash

# Define current script version (this value should be manually updated for each release)
SCRIPT_VERSION=1

# Retrieve the installed version (defaulting to 0 if not set)
INSTALLED_VERSION="${SEXY_BASH_INSTALLER_VERSION:-0}"

# Define unique markers for the block in .bashrc
MARKER_BEGIN="# >>> SEXY_BASH_PROMPT_BEGIN"
MARKER_END="# <<< SEXY_BASH_PROMPT_END"

# Function to install Sexy Bash
install_sexy_bash() {
  echo "🔧 Installing Sexy Bash (Version: $SCRIPT_VERSION)..."

  # Remove any existing Sexy Bash block from .bashrc
  sed -i "/$MARKER_BEGIN/,/$MARKER_END/d" ~/.bashrc

  # Add the Sexy Bash prompt installation block to .bashrc
  cat <<EOF >> ~/.bashrc
$MARKER_BEGIN
# Sexy Bash Prompt - Customized prompt with color and style
(cd /tmp && ([[ -d sexy-bash-prompt ]] || git clone --depth 1 --config core.autocrlf=false https://github.com/twolfson/sexy-bash-prompt) && cd sexy-bash-prompt && make install)
source ~/.bashrc
$MARKER_END
EOF

  echo "✅ Installed Sexy Bash"
  export SEXY_BASH_INSTALLER_VERSION="$SCRIPT_VERSION"
}

# Function to uninstall Sexy Bash
uninstall_sexy_bash() {
  echo "🧽 Removing Sexy Bash (Version: $INSTALLED_VERSION)..."

  # Remove the Sexy Bash block from .bashrc
  sed -i "/$MARKER_BEGIN/,/$MARKER_END/d" ~/.bashrc

  echo "✅ Removed Sexy Bash"
  unset SEXY_BASH_INSTALLER_VERSION
}

# Main control logic
if [[ "$SCRIPT_VERSION" -gt "$INSTALLED_VERSION" ]]; then
  if [[ "$INSTALLED_VERSION" -gt 0 ]]; then
    uninstall_sexy_bash
  fi
  install_sexy_bash
elif [[ "$SCRIPT_VERSION" -eq "$INSTALLED_VERSION" ]]; then
  echo "📦 Sexy Bash is already up-to-date (Version: $INSTALLED_VERSION)"
fi
