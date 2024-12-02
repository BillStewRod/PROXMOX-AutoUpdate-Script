# How to create a PROXMOX update script

<p>Below is the updated script that handles both the LXC containers and the Proxmox node.</p>

### Script name: 

	update-node-and-containers.sh

### Script

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
	
	echo "All updates completed: $(date)" >> "$LOGFILE"'

### Explanation of Node Update

<ol>
<li>Proxmox Node Update:</li>
<ul>
<li>The script runs apt update && apt upgrade -y on the host node (pve1).</li>
<li>Captures and logs the number of packages upgraded for the node.</li>
</ul>
<li>Log Details:</li>
<ul>
<li>Both the node and the containers log their respective outputs and upgraded package counts.</li>
</ul>
</ol>

### Scheduling Weekly Execution

Edit Crontab
<ol>
<li>Add the script to your crontab for weekly execution:</li>

	crontab -e

<li>Add this line to schedule the script every Sunday at midnight:</li>

	0 0 * * 0 /usr/local/bin/update-node-and-containers.sh

### Output Example

<p>When the script runs, the output will look like this:</p>

	Starting updates for node and containers: Sun Dec  1 00:00:00 UTC 2024
	------------------------------------------
	Updating Proxmox node (pve1)...
	Proxmox node: 8 packages upgraded.
	------------------------------------------
	Updating container ID: 101
	Container 101: 12 packages upgraded.
	------------------------------------------
	Updating container ID: 102
	Container 102: 0 packages upgraded.
	------------------------------------------
	Updating container ID: 103
	Container 103: 5 packages upgraded.
	------------------------------------------
	All updates completed: Sun Dec  1 00:10:00 UTC 2024

### Testing
<ol>
<li>Run the script manually to ensure both the node and containers are updated correctly:</li>

	sudo /usr/local/bin/update-node-and-containers.sh

<li>Check the logs:</li>
<ul>
	<li>The output is stored in /var/log/lxc-update.log.</li>
</ul>
</ol>

**Note:**
*Ensure the script is run with appropriate permissions (e.g., root) to allow updates on both the Proxmox node and containers.*
