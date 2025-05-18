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

    # Calculate total and mean runtime statistics
    echo -e "\nRuntime Statistics for $query_file:"
    cat "log_${query_file%.sql}.txt" | grep -oP 'Time: \d+\.\d+ ms' | sed -r -e 's/Time: ([0-9]+\.[0-9]+) ms/\1/' |
        awk '
        BEGIN { total = 0; count = 0; }
        { total += $1; count++; }
        END { 
            printf "Total runtime: %.3f ms\n", total;
            printf "Mean time per query: %.3f ms\n", total/count;
        }'
    
    echo -e "\n----------------------------------------\n"
done