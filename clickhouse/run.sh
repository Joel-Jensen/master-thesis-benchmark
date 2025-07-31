#!/bin/bash

TRIES=3
QUERY_NUM=1

QUERY_FILE=${1:-queries.sql}

# Get the base name of the query file for output file naming
QUERY_BASE=$(basename "$QUERY_FILE" .sql)

# Create output directory for monitoring data
MONITOR_DIR="monitoring_data"
mkdir -p "$MONITOR_DIR"

# Path to the monitoring script (assuming it's in the parent directory)
MONITOR_SCRIPT="../monitor_system.sh"

cat "$QUERY_FILE" | while read -r query; do
    [ -z "$FQDN" ] && sync
    [ -z "$FQDN" ] && sudo tee /proc/sys/vm/drop_caches >/dev/null <<< "3"

    echo "$query"
    
    # Start monitoring
    SYSTEM_MONITOR_FILE="$MONITOR_DIR/${QUERY_BASE}_system_$(date +%Y%m%d_%H%M%S).csv"
    
    # Start monitoring and get PID
    MONITOR_PID=$("$MONITOR_SCRIPT" "$SYSTEM_MONITOR_FILE")
    
    for i in $(seq 1 $TRIES); do
        echo "Run $i:"
        RES=$(clickhouse-client --host "${FQDN:=localhost}" --password "${PASSWORD:=}" ${PASSWORD:+--secure} --time --query="$query" --progress 0 2>&1)
        echo "$RES"
        echo "Time: $(echo "$(echo "$RES" | grep -o -P '^\d+\.\d+$') * 1000" | bc) ms"
    done
    
    # Stop monitoring
    kill "$MONITOR_PID" 2>/dev/null || true
    
    echo "Monitoring data saved to:"
    echo "  System: $SYSTEM_MONITOR_FILE"
    echo "----------------------------------------"

    QUERY_NUM=$((QUERY_NUM + 1))
done