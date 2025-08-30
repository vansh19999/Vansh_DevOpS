#!/usr/bin/env bash


# Define the directory to monitor
DOCKER_DIR="/var/lib/docker"
# Define the Docker volumes directory
DOCKER_VOLUME_DIR="/var/lib/docker/volumes"
# Log file
LOG_FILE="/var/log/skeps/cleanup_report.log"

# Define thresholds
# Threshold for old logs (in minutes)
THRESHOLD_LOG_MINUTES=720  # 12 hours = 720 minutes

# Threshold for file size
THRESHOLD_FILE_SIZE="+1M"

# Threshold for old Docker images
THRESHOLD_DOCKER_IMAGES="12h"


# Ensure log directory exists
mkdir -p "$(dirname "$LOG_FILE")"

# Function to get the usage percentage of the Docker directory
get_usage_percentage() {
  df -h "$DOCKER_DIR" | awk 'NR==2 {print $5}' | sed 's/%//'
}

# Function to clean up old Docker images
cleanup_docker_images() {

    # Remove dangling images older than threshold
    echo "[$(date)] Removing Docker images older than $THRESHOLD_DOCKER_IMAGES..." | tee -a "$LOG_FILE"
    docker image prune --all --force --filter "until=${THRESHOLD_DOCKER_IMAGES}" >> "$LOG_FILE" 2>&1
}

# Function to clean up old logs
cleanup_docker_logs() {
    echo "[$(date)] Removing log files older than $THRESHOLD_LOG_MINUTES minutes..." | tee -a "$LOG_FILE"
    find "${DOCKER_VOLUME_DIR}" -type f -size "${THRESHOLD_FILE_SIZE}" -name "*.log" -mmin +"${THRESHOLD_LOG_MINUTES}" -exec sh -c '
        echo "[$(date)] Deleting log file: $1" | tee -a "'"$LOG_FILE"'"
        rm -f "$1"
    ' sh {} \;
}

echo "[$(date)] Cleanup process started!" | tee -a "$LOG_FILE"

# Run cleanup tasks
cleanup_docker_images
cleanup_docker_logs

echo "[$(date)] Cleanup process completed successfully!" | tee -a "$LOG_FILE"