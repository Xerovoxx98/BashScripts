#!/bin/bash

# Script to SSH into a Proxmox host and execute a command in a PCT container using sshpass.
#
# !!! WARNING: Using sshpass is generally discouraged due to security risks associated with
# !!!          handling passwords in this manner. Consider using SSH keys for authentication. !!!
#
# Intended to be run from Cronicle, with parameters passed as environment variables.

# Proxmox host details
PROXMOX_HOST="${PROXMOX_HOST:-your_proxmox_host}"          # Default value if not set by Cronicle
PROXMOX_USER="${PROXMOX_USER:-your_proxmox_user}"          # Default value if not set by Cronicle
PROXMOX_PASSWORD="${PROXMOX_PASSWORD:-your_proxmox_password}" # Default value if not set by Cronicle
CONTAINER_ID="${CONTAINER_ID:-100}"                        # Default value if not set by Cronicle
CONTAINER_USER="${CONTAINER_USER:-root}"                   # Default value if not set by Cronicle

# Command to execute inside the container
CONTAINER_COMMAND="${CONTAINER_COMMAND:-curl -sSL myurl | bash}" # Default value if not set by Cronicle

# Function to execute the command with enhanced error handling.
execute_command_in_container() {
    local host="$1"
    local user="$2"
    local password="$3"
    local container_id="$4"
    local container_user="$5" # Added parameter for container user
    local command="$6"        # Adjusted parameter index

    local ssh_cmd_base="sshpass -p \"$password\" ssh -o StrictHostKeyChecking=no -o ConnectTimeout=10"
    local target="$user@$host"

    echo "--- Checking status of container $container_id on host $host ---"

    # Attempt to get container status, capturing output and exit code.
    # We capture stderr (2>&1) as errors from SSH or pct might go there.
    local status_output
    local status_exit_code

    status_output=$(eval "$ssh_cmd_base $target \"pct status $container_id\"" 2>&1)
    status_exit_code=$?

    # Check if the pct status command itself failed (SSH error, command not found, container doesn't exist, etc.)
    if [ $status_exit_code -ne 0 ]; then
        echo "ERROR: Failed to execute 'pct status $container_id' on host $host."
        echo "Exit Code: $status_exit_code"
        echo "Output/Error:"
        echo "$status_output"
        return 1
    fi

    # Check if the status output indicates the container is running.
    # Use grep -q for a silent check.
    if echo "$status_output" | grep -q "status: running"; then
        echo "Container $container_id status is 'running'."
    else
        echo "ERROR: Container $container_id on host $host is not running or status check returned unexpected output."
        echo "Actual Status Output:"
        echo "$status_output"
        return 1
    fi

    echo "--- Executing command in container $container_id ---"
    echo "Command: $command"

    local exec_exit_code

    # Revised command execution: Removed 'eval', use correct '$container_user' variable
    sshpass -p "$password" ssh -o StrictHostKeyChecking=no -o ConnectTimeout=10 -t -t \
        "$target" \
        "pct exec $container_id --user $container_user -- bash -c '$command'" # Use $container_user here

    exec_exit_code=$?

    if [ $exec_exit_code -eq 0 ]; then
        echo "Command executed successfully in container $container_id."
        return 0
    else
        echo "ERROR: Failed to execute command in container $container_id."
        echo "Exit Code: $exec_exit_code"
        # Error message from the remote command itself should have been printed directly
        # to the log just before this error message (as seen in the log provided).
        return 1
    fi
}

# --- Main script logic ---
echo "Starting script to execute command in Proxmox container."
start_time=$(date +%s)

# Output the parameters being used (mask password)
echo "Using parameters:"
echo "  PROXMOX_HOST:      $PROXMOX_HOST"
echo "  PROXMOX_USER:      $PROXMOX_USER"
echo "  PROXMOX_PASSWORD:  <hidden>"
echo "  CONTAINER_ID:      $CONTAINER_ID"
echo "  CONTAINER_USER:    $CONTAINER_USER"
echo "  CONTAINER_COMMAND: $CONTAINER_COMMAND"
echo "----------------------------------------"

# Validate essential parameters
if [[ "$PROXMOX_HOST" == "your_proxmox_host" || "$PROXMOX_USER" == "your_proxmox_user" || "$PROXMOX_PASSWORD" == "your_proxmox_password" ]]; then
    echo "ERROR: Proxmox connection details (Host, User, Password) are not set or are using default placeholder values."
    echo "Please set PROXMOX_HOST, PROXMOX_USER, and PROXMOX_PASSWORD environment variables."
    exit 1
fi

# Execute the command in the container.
execute_command_in_container "$PROXMOX_HOST" "$PROXMOX_USER" "$PROXMOX_PASSWORD" "$CONTAINER_ID" "$CONTAINER_USER" "$CONTAINER_COMMAND"
script_exit_code=$?

echo "----------------------------------------"
end_time=$(date +%s)
duration=$((end_time - start_time))

if [ $script_exit_code -eq 0 ]; then
  echo "Script finished successfully in ${duration}s."
else
  echo "Script finished with errors in ${duration}s."
fi

exit $script_exit_code