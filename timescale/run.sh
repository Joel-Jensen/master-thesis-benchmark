#!/bin/bash

TRIES=3
QUERY_FILE=${1:-queries.sql}

# Get the base name of the query file for output file naming
QUERY_BASE=$(basename "$QUERY_FILE" .sql)

# Create output directory for monitoring data
MONITOR_DIR="monitoring_data"
mkdir -p "$MONITOR_DIR"

# Path to the monitoring script (assuming it's in the parent directory)
MONITOR_SCRIPT="../monitor_system.sh"

# Start monitoring before processing queries
SYSTEM_MONITOR_FILE="$MONITOR_DIR/${QUERY_BASE}_system_$(date +%Y%m%d_%H%M%S).csv"

# Start monitoring and get PID
MONITOR_PID=$("$MONITOR_SCRIPT" "$SYSTEM_MONITOR_FILE")

cat "$QUERY_FILE" | while read -r query; do
    sync
    sudo tee /proc/sys/vm/drop_caches >/dev/null <<< "3"

    echo "$query"
    
    (
        echo '\timing'
        yes "$query" | head -n $TRIES
    ) | sudo -u postgres psql test -t
    
    echo "----------------------------------------"
done

# Stop monitoring after all queries are complete
kill "$MONITOR_PID" 2>/dev/null || true

echo "Monitoring data saved to:"
echo "  System: $SYSTEM_MONITOR_FILE"