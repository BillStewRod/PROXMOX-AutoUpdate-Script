# PROXMOX-Scripts

Below is an example Bash script that iterates through all LXC containers and runs the update and upgrade commands within each container:

Script: update-containers.sh

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

Steps to Implement

	1.	Create the Script File:
	•	Save the script above to a file, e.g., /usr/local/bin/update-containers.sh.
	2.	Make the Script Executable:

chmod +x /usr/local/bin/update-containers.sh


	3.	Schedule Weekly Execution with Cron:
	•	Edit the crontab:

crontab -e


	•	Add the following line to run the script every week, e.g., Sunday at midnight:

0 0 * * 0 /usr/local/bin/update-containers.sh


	4.	Optional: Test the Script:
	•	Run the script manually to ensure it works as expected:

sudo /usr/local/bin/update-containers.sh



Notes

	•	Log File: Updates are logged in /var/log/lxc-update.log for later review.
	•	Error Handling: You can expand the script to include error handling for specific edge cases (e.g., containers that fail to update).
	•	Customization: Modify the apt commands to suit your environment (e.g., adding autoremove or clean).

This approach keeps your Proxmox containers updated automatically and ensures a centralized log for monitoring.
