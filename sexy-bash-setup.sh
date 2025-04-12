#!/bin/bash

# --- Configuration ---
SCRIPT_VERSION=1
INSTALL_DIR="$HOME/.sexy-bash-prompt" # Install location
REPO_URL="https://github.com/twolfson/sexy-bash-prompt"
BASHRC_FILE="$HOME/.bashrc"
PROFILE_FILE="$HOME/.bash_profile" # Or ~/.profile if .bash_profile doesn't exist
MARKER_BEGIN="# >>> SEXY_BASH_PROMPT_BEGIN"
MARKER_END="# <<< SEXY_BASH_PROMPT_END"
VERSION_VAR_NAME="SEXY_BASH_INSTALLER_VERSION"

# Determine the correct profile file to modify
TARGET_RC_FILE="$BASHRC_FILE"
if [[ -f "$PROFILE_FILE" ]]; then
    TARGET_RC_FILE="$PROFILE_FILE"
elif [[ -f "$HOME/.profile" ]]; then
     TARGET_RC_FILE="$HOME/.profile"
fi
# Check if running interactively before sourcing .bashrc in profile
NEEDS_BASHRC_SOURCE=false
if [[ "$TARGET_RC_FILE" != "$BASHRC_FILE" ]] && ! grep -q 'source ~/.bashrc' "$TARGET_RC_FILE"; then
    NEEDS_BASHRC_SOURCE=true
fi


# --- Helper Functions ---

# Function to add source line to the target RC file
add_source_line() {
    echo "✏️ Adding source line to $TARGET_RC_FILE..."
    # Remove existing block first
    sed -i.bak "/$MARKER_BEGIN/,/$MARKER_END/d" "$TARGET_RC_FILE"

    # Add new block
    cat <<EOF >> "$TARGET_RC_FILE"
$MARKER_BEGIN
# Load Sexy Bash Prompt settings
if [ -f "$INSTALL_DIR/sexy-bash-prompt.sh" ]; then
  source "$INSTALL_DIR/sexy-bash-prompt.sh"
fi
# Store installed version
export $VERSION_VAR_NAME="$SCRIPT_VERSION"
$MARKER_END
EOF

    # If modifying a profile file, ensure .bashrc is sourced for interactive shells
    if $NEEDS_BASHRC_SOURCE; then
        echo "ℹ️ Adding source for .bashrc in $TARGET_RC_FILE for interactive shells..."
        cat <<EOF >> "$TARGET_RC_FILE"

# Source .bashrc for interactive shells if it exists
if [ -n "\$BASH_VERSION" ]; then
    # include .bashrc if it exists
    if [ -f "\$HOME/.bashrc" ]; then
        . "\$HOME/.bashrc"
    fi
fi
EOF
    fi

    echo "✅ Source line added."
}

# Function to remove source line
remove_source_line() {
    echo "✏️ Removing source line from $TARGET_RC_FILE..."
    sed -i.bak "/$MARKER_BEGIN/,/$MARKER_END/d" "$TARGET_RC_FILE"
    # Attempt to clean up the version variable export if it exists elsewhere,
    # though ideally it should only be within the markers.
    sed -i.bak "/export $VERSION_VAR_NAME=/d" "$TARGET_RC_FILE"
    echo "✅ Source line removed."
}

# Function to install/update Sexy Bash Prompt files
install_sexy_bash_files() {
    echo "🔧 Installing/Updating Sexy Bash Prompt files (Version: $SCRIPT_VERSION)..."
    if [ -d "$INSTALL_DIR" ]; then
        echo "Updating existing installation in $INSTALL_DIR..."
        (cd "$INSTALL_DIR" && git pull)
        if [ $? -ne 0 ]; then
            echo "❌ Git pull failed. Attempting fresh clone."
            rm -rf "$INSTALL_DIR"
            git clone --depth 1 --config core.autocrlf=false "$REPO_URL" "$INSTALL_DIR"
        fi
    else
        echo "Cloning repository to $INSTALL_DIR..."
        git clone --depth 1 --config core.autocrlf=false "$REPO_URL" "$INSTALL_DIR"
    fi

    if [ $? -ne 0 ]; then
       echo "❌ Failed to clone repository. Aborting."
       exit 1
    fi

    # Note: The original 'make install' often just copies files or sources them.
    # We'll source directly from the install dir instead of running make install.
    # If 'make install' does something more complex, that logic needs review.
    # For this specific repo, make install seems to just copy bashrc-main.sh
    # and suggest sourcing it, which we handle via add_source_line.
    if [ -f "$INSTALL_DIR/sexy-bash-prompt.sh" ]; then
        echo "✅ Files installed/updated successfully."
        return 0
    else
        echo "❌ Installation failed: sexy-bash-prompt.sh not found in $INSTALL_DIR."
        return 1
    fi
}

# Function to uninstall Sexy Bash Prompt
uninstall_sexy_bash() {
    INSTALLED_VERSION=$(grep "export $VERSION_VAR_NAME=" "$TARGET_RC_FILE" | sed 's/.*=//')
    echo "🧽 Uninstalling Sexy Bash Prompt (Installed Version: ${INSTALLED_VERSION:-Not found})..."
    remove_source_line
    if [ -d "$INSTALL_DIR" ]; then
        echo "🗑️ Removing installation directory: $INSTALL_DIR..."
        rm -rf "$INSTALL_DIR"
        echo "✅ Directory removed."
    else
        echo "🤷 Installation directory not found."
    fi
    echo "✅ Uninstallation complete. You may need to start a new shell."
}


# --- Main Logic ---

# Simple argument parsing
if [[ "$1" == "uninstall" ]]; then
    uninstall_sexy_bash
    exit 0
fi

# Check current installed version by sourcing the RC file carefully
# We grep for the specific export line within the markers
CURRENT_INSTALLED_VERSION=0
if grep -q "$MARKER_BEGIN" "$TARGET_RC_FILE"; then
    VERSION_LINE=$(sed -n "/$MARKER_BEGIN/,/$MARKER_END/p" "$TARGET_RC_FILE" | grep "export $VERSION_VAR_NAME=")
    if [[ -n "$VERSION_LINE" ]]; then
        CURRENT_INSTALLED_VERSION=$(echo "$VERSION_LINE" | sed 's/.*=//')
        # Validate if it's a number
        if ! [[ "$CURRENT_INSTALLED_VERSION" =~ ^[0-9]+$ ]]; then
            CURRENT_INSTALLED_VERSION=0
        fi
    fi
fi


echo "Current Script Version: $SCRIPT_VERSION"
echo "Detected Installed Version: $CURRENT_INSTALLED_VERSION"

if [[ "$SCRIPT_VERSION" -gt "$CURRENT_INSTALLED_VERSION" ]]; then
    echo "🚀 New version available or not installed. Proceeding with installation/update..."
    if install_sexy_bash_files; then
        add_source_line
        echo "🎉 Sexy Bash Prompt installed/updated successfully!"
        echo "Please start a new shell or run 'source $TARGET_RC_FILE' for changes to take effect."
    else
        echo "❌ Installation failed."
        exit 1
    fi
elif [[ "$SCRIPT_VERSION" -eq "$CURRENT_INSTALLED_VERSION" ]]; then
    echo "✅ Sexy Bash Prompt is already up-to-date (Version: $CURRENT_INSTALLED_VERSION)."
    # Optionally add a check to ensure files exist and source line is present
    if ! [ -f "$INSTALL_DIR/sexy-bash-prompt.sh" ]; then
      echo "⚠️ Files seem missing. Reinstalling..."
      if install_sexy_bash_files; then
          add_source_line
          echo "🎉 Sexy Bash Prompt files restored!"
          echo "Please start a new shell or run 'source $TARGET_RC_FILE' for changes to take effect."
      else
          echo "❌ Reinstallation failed."
          exit 1
      fi
    elif ! grep -q "$MARKER_BEGIN" "$TARGET_RC_FILE"; then
        echo "⚠️ Source line missing in $TARGET_RC_FILE. Adding it back..."
        add_source_line
        echo "✅ Source line restored."
        echo "Please start a new shell or run 'source $TARGET_RC_FILE' for changes to take effect."
    fi
else
     echo "🤔 Installed version ($CURRENT_INSTALLED_VERSION) is newer than script version ($SCRIPT_VERSION). No action taken."
fi

exit 0
