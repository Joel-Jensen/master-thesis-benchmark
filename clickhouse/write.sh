#!/bin/bash

set -eu

echo "=== ClickHouse Insert Performance Benchmark ==="
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
    clickhouse-client --host "${FQDN:=localhost}" --password "${PASSWORD:=}" ${PASSWORD:+--secure} --query="INSERT INTO transactions (id, user_id, amount, type, country_code, platform, created_at) VALUES (99999999$i, $user_id, 150, 'purchase', 'SE', 'web', '2025-01-01 00:00:0$i');"
    
    # End timing
    end_time=$(date +%s.%N)
    
    # Calculate duration in milliseconds
    duration=$(echo "($end_time - $start_time) * 1000" | bc -l)
    insert_times+=($duration)
    
    echo "Row $i inserted in ${duration}ms"
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

echo "Total time for 10 inserts: ${total_time}ms"
echo "Average time per insert: ${avg_time}ms"
echo ""

# Delete the 10 inserted rows
echo "Cleaning up inserted rows..."
clickhouse-client --host "${FQDN:=localhost}" --password "${PASSWORD:=}" ${PASSWORD:+--secure} --query="DELETE FROM transactions WHERE id >= 999999991;"

echo "Cleanup completed." 