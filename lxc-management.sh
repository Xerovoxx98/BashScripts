#!/bin/bash

# Script to SSH into a Proxmox host and execute a command in a PCT container using sshpass.
#
# !!! WARNING: Using sshpass is generally discouraged due to security risks associated with
# !!!          handling passwords in this manner.  Consider using SSH keys for authentication. !!!
#
# Intended to be run from Cronicle, with parameters passed as environment variables.

# Proxmox host details
PROXMOX_HOST="${PROXMOX_HOST:-your_proxmox_host}"  # Default value if not set by Cronicle
PROXMOX_USER="${PROXMOX_USER:-your_proxmox_user}"  # Default value if not set by Cronicle
PROXMOX_PASSWORD="${PROXMOX_PASSWORD:-your_proxmox_password}"  # Default value if not set by Cronicle
CONTAINER_ID="${CONTAINER_ID:-100}"             # Default value if not set by Cronicle
CONTAINER_USER="${CONTAINER_USER:-root}"           # Default value if not set by Cronicle

# Command to execute inside the container
CONTAINER_COMMAND="${CONTAINER_COMMAND:-curl -sSL myurl | bash}" # Default value if not set by Cronicle

# Function to execute the command with error handling.
execute_command_in_container() {
    local host="$1"
    local user="$2"
    local password="$3"
    local container_id="$4"
    local command="$5"

    # Check if the container exists before attempting to execute command.
    pct status "$container_id" >/dev/null 2>&1
    if [ $? -ne 0 ]; then
        echo "Container $container_id does not exist or is not running."
        return 1
    fi

    echo "Executing command in container $container_id on host $host:"
    echo "  $command"

    # Use sshpass to provide the password and execute the command.
    sshpass -p "$password" ssh -o StrictHostKeyChecking=no -t -t \
        "$user@$host" "pct exec $container_id --user $CONTAINER_USER -- $command"

    if [ $? -eq 0 ]; then
        echo "Command executed successfully."
        return 0
    else
        echo "Failed to execute command."
        return 1
    fi
}

# Main script logic.
echo "Starting script to execute command in Proxmox container."

# Output the parameters being used
echo "Using parameters:"
echo "  PROXMOX_HOST:     $PROXMOX_HOST"
echo "  PROXMOX_USER:     $PROXMOX_USER"
echo "  CONTAINER_ID:     $CONTAINER_ID"
echo "  CONTAINER_USER:     $CONTAINER_USER"
echo "  CONTAINER_COMMAND:  $CONTAINER_COMMAND"

# Execute the command in the container.
execute_command_in_container "$PROXMOX_HOST" "$PROXMOX_USER" "$PROXMOX_PASSWORD" "$CONTAINER_ID" "$CONTAINER_COMMAND"

echo "Script finished."