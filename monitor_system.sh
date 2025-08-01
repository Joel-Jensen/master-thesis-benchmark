#!/bin/bash

# Generic System Monitoring Script
# Usage: ./monitor_system.sh <output_file>
# Returns: PID of the monitoring process

set -e

OUTPUT_FILE="$1"

if [ -z "$OUTPUT_FILE" ]; then
    echo "Usage: $0 <output_file>"
    echo "Example: $0 monitoring_data/test_system_20241201_120000.csv"
    echo "Returns: PID of the monitoring process"
    exit 1
fi

# Create output directory if it doesn't exist
OUTPUT_DIR=$(dirname "$OUTPUT_FILE")
mkdir -p "$OUTPUT_DIR"

# Function to get system-wide CPU and memory usage
monitor_system() {
    local output_file="$1"
    
    (
        echo "timestamp,cpu_percent,memory_percent,memory_available_mb"
        while true; do
            timestamp=$(date +%s.%3N)
            # Get CPU usage from /proc/stat
            cpu_line=$(head -n 1 /proc/stat)
            cpu_values=($cpu_line)
            cpu_idle=${cpu_values[4]}
            cpu_total=0
            for i in {1..4}; do
                cpu_total=$((cpu_total + ${cpu_values[i]}))
            done
            cpu_percent=$((100 - (cpu_idle * 100 / cpu_total)))
            
            # Get memory usage
            memory_line=$(free | grep Mem)
            memory_values=($memory_line)
            memory_total=${memory_values[1]}
            memory_used=${memory_values[2]}
            memory_available=${memory_values[6]}
            memory_percent=$(echo "scale=1; $memory_used * 100 / $memory_total" | bc -l)
            
            echo "$timestamp,$cpu_percent,$memory_percent,$memory_available"
            sleep 1
        done
    ) > "$output_file" &
    
    echo $!
}

# Start monitoring and return PID
MONITOR_PID=$(monitor_system "$OUTPUT_FILE")
echo "$MONITOR_PID" 