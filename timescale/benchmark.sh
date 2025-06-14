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
    #./../result.sh "$query_file"
done

echo "All results:"
for query_file in "${QUERY_FILES[@]}"; do
    ./../result.sh "$query_file"
done