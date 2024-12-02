#!/bin/bash

# Log file for update output
LOGFILE="/var/log/lxc-update.log"

# Get a list of all LXC container IDs
CONTAINERS=$(pct list | awk 'NR>1 {print $1}')

# Start logging
echo "Starting container updates: $(date)" >> "$LOGFILE"

# Loop through each container and perform updates
for CTID in $CONTAINERS; do
    echo "Updating container ID: $CTID" | tee -a "$LOGFILE"
    
    # Check if the container is running
    if pct status $CTID | grep -q "status: running"; then
        # Run apt update and upgrade inside the container
        pct exec $CTID -- bash -c "apt update && apt upgrade -y" | tee -a "$LOGFILE"
    else
        echo "Container $CTID is not running. Skipping." | tee -a "$LOGFILE"
    fi
done

echo "All updates completed: $(date)" >> "$LOGFILE"
