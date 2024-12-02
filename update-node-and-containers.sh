#!/bin/bash

# Log file for update output
LOGFILE="/var/log/lxc-update.log"

# Start logging
echo "Starting updates for node and containers: $(date)" >> "$LOGFILE"
echo "------------------------------------------" >> "$LOGFILE"

# Step 1: Update the Proxmox node (pve1)
echo "Updating Proxmox node (pve1)..." | tee -a "$LOGFILE"
NODE_OUTPUT=$(apt update && apt upgrade -y)
NODE_UPGRADED=$(echo "$NODE_OUTPUT" | grep -Po '\d+ upgraded' | grep -Po '\d+')
NODE_UPGRADED=${NODE_UPGRADED:-0}
echo "Proxmox node: $NODE_UPGRADED packages upgraded." | tee -a "$LOGFILE"
echo "------------------------------------------" | tee -a "$LOGFILE"

# Step 2: Get a list of all LXC container IDs
CONTAINERS=$(pct list | awk 'NR>1 {print $1}')

# Loop through each container and perform updates
for CTID in $CONTAINERS; do
    echo "Updating container ID: $CTID" | tee -a "$LOGFILE"
    
    # Check if the container is running
    if pct status $CTID | grep -q "status: running"; then
        # Run apt update and capture upgrade details
        OUTPUT=$(pct exec $CTID -- bash -c "apt update && apt upgrade -y")
        
        # Extract the number of packages upgraded from the output
        UPGRADED=$(echo "$OUTPUT" | grep -Po '\d+ upgraded' | grep -Po '\d+')
        
        # If no packages were upgraded, set UPGRADED to 0
        UPGRADED=${UPGRADED:-0}
        
        echo "Container $CTID: $UPGRADED packages upgraded." | tee -a "$LOGFILE"
    else
        echo "Container $CTID is not running. Skipping." | tee -a "$LOGFILE"
    fi
    
    echo "------------------------------------------" | tee -a "$LOGFILE"
done

echo "All updates completed: $(date)" >> "$LOGFILE"
