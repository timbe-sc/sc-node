#!/bin/bash

# Configuration
SERVICE_NAME="whoami"
LOCAL_REPO_PATH="$HOME/.tuumio"
REMOTE_REPO_URL="https://github.com/timbe-sc/sc-node.git"
REMOTE_BRANCH="main"
CONTROL_SCRIPT="tuumio-node-control.sh"
LOG_FILE="$HOME/.tuumio/manager.log"

# Logging function
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1"
}

# Check if service is running
is_service_running() {
    sh $CONTROL_SCRIPT status
    return $?
}

# Start service
start_service() {
    log "Starting service $SERVICE_NAME"
    sh $CONTROL_SCRIPT start
}

# Check for new version
check_for_updates() {
    cd "$LOCAL_REPO_PATH" || return 1

    # Fetch remote hash for specific branch
    git checkout $REMOTE_BRANCH
    local remote_hash=$(git ls-remote "$REMOTE_REPO_URL" "$REMOTE_BRANCH" | cut -f1)
    local local_hash=$(git rev-parse "$REMOTE_BRANCH")

    if [ "$remote_hash" != "$local_hash" ]; then
        log "New version detected on branch $REMOTE_BRANCH. Pulling updates."

        # Stop current service
        sh $CONTROL_SCRIPT stop

        # Fetch and reset to remote branch
        git reset --hard HEAD
        git pull

        # Ensure control script is executable
        chmod +x "$CONTROL_SCRIPT"

        # Run migration
        sh $CONTROL_SCRIPT migrate

        # Start service with new configuration
        start_service
    else
        log "No updates detected on branch $REMOTE_BRANCH."
    fi
}

# Main monitoring function
monitor_service() {
    # Initialize repo if not existing
    if [ ! -d "$LOCAL_REPO_PATH/.git" ]; then
        log "Initializing repository from branch $REMOTE_BRANCH"
        mkdir -p "$LOCAL_REPO_PATH"
        cd "$LOCAL_REPO_PATH"
        git clone -b "$REMOTE_BRANCH" "$REMOTE_REPO_URL" .
        chmod +x "$CONTROL_SCRIPT"
    fi

    check_for_updates

    # Check service status and update
    if ! is_service_running; then
        log "Service not running. Starting."
        start_service
    fi
}

# Run with proper permissions
#if [ "$EUID" -ne 0 ]; then
#    log "Please run as root"
#    exit 1
#fi

monitor_service
#"$@"