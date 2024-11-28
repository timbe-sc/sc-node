#!/bin/bash

# Path to docker-compose file
DOCKER_COMPOSE_FILE="docker-compose.yml"

# Logging function
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1"
}

# Start the service
start() {
    log "Starting service"
    docker-compose -f "$DOCKER_COMPOSE_FILE" up -d
}

# Stop the service
stop() {
    log "Stopping service"
    docker-compose -f "$DOCKER_COMPOSE_FILE" down
}

# Check service status
status() {
    docker-compose -f "$DOCKER_COMPOSE_FILE" ps | grep -q "Up"
    return $?
}

# Migration script - customize as needed
migrate() {
    log "Running migration"
    # Add any necessary migration steps
    # For example:
    # - Database migrations
    # - Configuration updates
    # - Backup current data
    # docker-compose exec service-name some-migration-command
}

# Handle command
case "$1" in
    start)
        start
        ;;
    stop)
        stop
        ;;
    status)
        status
        ;;
    migrate)
        migrate
        ;;
    *)
        echo "Usage: $0 {start|stop|status|migrate}"
        exit 1
esac

exit 0