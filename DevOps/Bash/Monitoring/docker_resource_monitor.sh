#!/bin/bash
set -euo pipefail

# ========================================================
# Azure VM Resource Monitoring & Cleanup Script
# ========================================================
# Author : Vansh Pundir
# Purpose: Monitors Azure VM disk usage and performs cleanup
#          if usage crosses a defined threshold.
# ========================================================

# Configurable parameters
THRESHOLD=80                # Disk usage % threshold
CLEANUP_LOG="/var/log/azure_vm_cleanup.log"
DATE=$(date +"%Y-%m-%d %H:%M:%S")

# Function: log message with timestamp
log_message() {
    echo "[$DATE] $1" | tee -a "$CLEANUP_LOG"
}

# Function: check and clean VM disk usage
check_and_cleanup() {
    USAGE=$(df -h / | awk 'NR==2 {print $5}' | sed 's/%//')
    log_message "Current disk usage: $USAGE%"

    if [ "$USAGE" -ge "$THRESHOLD" ]; then
        log_message "Disk usage above threshold ($THRESHOLD%). Starting cleanup..."

        # Example cleanup tasks (can be customized):
        sudo journalctl --vacuum-time=7d || true
        sudo apt-get autoremove -y || true
        sudo apt-get clean || true
        sudo rm -rf /tmp/* || true

        NEW_USAGE=$(df -h / | awk 'NR==2 {print $5}' | sed 's/%//')
        log_message "Cleanup complete. New usage: $NEW_USAGE%"
    else
        log_message "Disk usage is under control. No cleanup required."
    fi
}

# ===============================
# Main Execution
# ===============================
log_message "Azure VM Resource Monitoring Script Started"
check_and_cleanup
log_message "Script execution finished"
