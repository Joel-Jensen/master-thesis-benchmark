#!/bin/bash

set -eux

# Check if strategy parameter is provided
if [ $# -eq 0 ]; then
    echo "Usage: $0 <strategy>"
    exit 1
fi

STRATEGY=$1

echo "=== Insert Performance Benchmark ==="
echo "Strategy: $STRATEGY"
echo ""

# Array to store individual insert times
declare -a insert_times

# Insert 10 rows and measure each insert time
for i in {1..10}; do
    echo "Inserting row $i..."
    
    # Start timing
    start_time=$(date +%s.%N)
    
    user_id=$((i*1000 + 1))
    # Insert a hardcoded row
    sudo -u postgres psql test -t -c "INSERT INTO transactions (id, user_id, amount, type, country_code, platform, created_at) VALUES (99999999$i, $user_id, 150.50, 'purchase', 'SE', 'web', '2025-01-01 00:00:0$i');"
    
    # End timing
    end_time=$(date +%s.%N)
    
    # Calculate duration
    duration=$(echo "$end_time - $start_time" | bc -l)
    insert_times+=($duration)
    
    echo "Row $i inserted in ${duration}s"
done

echo ""
echo "=== Results ==="

# Calculate total time
total_time=0
for time in "${insert_times[@]}"; do
    total_time=$(echo "$total_time + $time" | bc -l)
done

# Calculate average time
avg_time=$(echo "$total_time / ${#insert_times[@]}" | bc -l)

echo "Total time for 10 inserts: ${total_time}s"
echo "Average time per insert: ${avg_time}s"
echo ""

# Delete the 10 inserted rows
echo "Cleaning up inserted rows..."
sudo -u postgres psql test -t -c "DELETE FROM transactions WHERE id >= 999999991 AND id <= 9999999100;"

echo "Cleanup completed." 