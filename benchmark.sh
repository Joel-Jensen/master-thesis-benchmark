#!/bin/bash

# Always set -eu flags
set -eu

# Parse command line arguments
while getopts "d" opt; do
  case $opt in
    d)
      set -x
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      exit 1
      ;;
  esac
done

PGVERSION=17

echo "Database size:"
sudo du -bcs /var/lib/postgresql/$PGVERSION/main/

# Array of query files to test
QUERY_FILES=("queries.sql" "queries_2024.sql" "queries_1y.sql")

for query_file in "${QUERY_FILES[@]}"; do
    echo "Running benchmark with $query_file"
    ./run.sh "$query_file" 2>&1 | tee "log_${query_file%.sql}.txt"

    echo "Results for $query_file:"
    cat "log_${query_file%.sql}.txt" | grep -oP 'Time: \d+\.\d+ ms' | sed -r -e 's/Time: ([0-9]+\.[0-9]+) ms/\1/' |
        awk '{ if (i % 3 == 0) { printf "[" }; printf $1 / 1000; if (i % 3 != 2) { printf "," } else { print "]," }; ++i; }'

    # Calculate total, mean runtime statistics, and find the query with highest minimum time
    echo -e "\nRuntime Statistics for $query_file:"
    cat "log_${query_file%.sql}.txt" | grep -oP 'Time: \d+\.\d+ ms' | sed -r -e 's/Time: ([0-9]+\.[0-9]+) ms/\1/' |
        awk '
        BEGIN { 
            total = 0; 
            count = 0;
            # Initialize arrays to store times for each query
            for (i = 0; i < 3; i++) {
                min_times[i] = 999999;
            }
        }
        { 
            total += $1; 
            count++;
            # Store minimum time for each query (3 runs per query)
            query_idx = (count - 1) % 3;
            if ($1 < min_times[query_idx]) {
                min_times[query_idx] = $1;
            }
        }
        END { 
            printf "Total runtime: %.3f ms\n", total;
            printf "Mean time per query: %.3f ms\n", total/count;
            
            # Find query with highest minimum time
            max_min_time = 0;
            max_min_query = 0;
            for (i = 0; i < 3; i++) {
                if (min_times[i] > max_min_time) {
                    max_min_time = min_times[i];
                    max_min_query = i + 1;
                }
            }
            printf "Query with highest minimum time: Query %d (%.3f ms)\n", max_min_query, max_min_time;
        }'
    
    echo -e "\n----------------------------------------\n"
done