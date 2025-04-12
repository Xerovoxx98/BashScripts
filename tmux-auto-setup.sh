#!/bin/bash

# Define current script version (this value should be manually updated for each release)
SCRIPT_VERSION=1

# Retrieve the installed version (defaulting to 0 if not set)
INSTALLED_VERSION="${TMUX_AUTOSESSION_INSTALLER_VERSION:-0}"

# Define unique marker for your block in .bashrc
MARKER_BEGIN="# >>> TMUX_AUTOSESSION_BEGIN"
MARKER_END="# <<< TMUX_AUTOSESSION_END"

# Function to install tmux auto-attach config
install_tmux_autosession() {
  echo "🔧 Setting up tmux autosession (Version: $SCRIPT_VERSION)..."

  # Remove any existing block from .bashrc
  sed -i "/$MARKER_BEGIN/,/$MARKER_END/d" ~/.bashrc

  # Add fresh block to .bashrc
  cat <<EOF >> ~/.bashrc
$MARKER_BEGIN
# Automatically create or attach to a tmux session named after the hostname
# Only if running interactively, not already in tmux, and tmux is available
if [[ "\$-" == *i* ]] && [[ -z "\$TMUX" ]] && command -v tmux &> /dev/null; then
    TMUX_SESSION_NAME=\$(hostname -s)

    if tmux has-session -t "\$TMUX_SESSION_NAME" 2>/dev/null; then
        echo "🔄 Attaching to existing tmux session: \$TMUX_SESSION_NAME"
        tmux attach-session -t "\$TMUX_SESSION_NAME"
    else
        echo "🚀 Creating new tmux session: \$TMUX_SESSION_NAME"
        tmux new-session -s "\$TMUX_SESSION_NAME"
    fi
fi
$MARKER_END
EOF

  echo "✅ Tmux autosession configured"
  export TMUX_AUTOSESSION_INSTALLER_VERSION="$SCRIPT_VERSION"
}

# Function to uninstall tmux config
uninstall_tmux_autosession() {
  echo "🧽 Removing tmux autosession (Version: $INSTALLED_VERSION)..."
  sed -i "/$MARKER_BEGIN/,/$MARKER_END/d" ~/.bashrc
  echo "✅ Removed tmux autosession"
  unset TMUX_AUTOSESSION_INSTALLER_VERSION
}

# Main control logic
if [[ "$SCRIPT_VERSION" -gt "$INSTALLED_VERSION" ]]; then
  if [[ "$INSTALLED_VERSION" -gt 0 ]]; then
    uninstall_tmux_autosession
  fi
  install_tmux_autosession
elif [[ "$SCRIPT_VERSION" -eq "$INSTALLED_VERSION" ]]; then
  echo "📦 Tmux autosession is already up-to-date (Version: $INSTALLED_VERSION)"
fi