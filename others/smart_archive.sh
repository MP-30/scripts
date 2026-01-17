#!/bin/bash

set -Eeuo pipefail

trap 'echo "Something bad happened"' ERR

LOG_DIR="/var/app/logs"
BACKUP_DIR="/var/app/backups"

SCRIPT_DATE=$(date %Y-%m-%d)

$(date +%F)

BACKUP_PATH="$BACKUP_DIR/$SCRIPT_DATE"

mkdir -p "$BACKUP_PATH"

find "$LOG_DIR" -type f -name "*.log" -size +10k | while IFS= read -r logfile 
do
    filename=$(basename "$logfile")
    mv  "$logfile" "$BACKUP_PATH/$filename.bak"
done

#!/bin/bash

# Set dynamic directory variable using date command - generates current date in YYYY-MM-DD format
# +%F flag outputs date in ISO 8601 format (year-month-day) needed for organized backup directories
TODAY=$(date +%F)
BACKUP_DIR="/var/app/backups/$TODAY"

# Create the backup directory with parent directories if they don't exist - ensures backup path is ready
# -p flag creates parent directories (/var/app/backups) if missing and doesn't error if directory exists
mkdir -p "$BACKUP_DIR"

# Find files larger than 10KB with .log extension and process each one
# -name "*.log" filters for log files only, -size +10k finds files strictly greater than 10KB
# 'while read FILE' reads each found file path into the FILE variable for processing
find /var/app/logs -name "*.log" -size +10k | while read FILE; do
  # Extract just the filename (e.g., app.log) from the full path - needed for renaming
  # basename removes the directory path, leaving only the filename
  FILENAME=$(basename "$FILE")
  
  # Move the file to backup directory and append .bak extension - archives file with renamed backup format
  # "$FILE" is the source (original location), "$BACKUP_DIR/$FILENAME.bak" is destination with .bak extension
  # This operation both moves and renames in a single command
  mv "$FILE" "$BACKUP_DIR/$FILENAME.bak"
done
