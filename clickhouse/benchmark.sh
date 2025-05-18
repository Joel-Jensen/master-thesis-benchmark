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

# Array of query files to test
QUERY_FILES=("queries.sql" "queries_2024.sql" "queries_1y.sql")

for query_file in "${QUERY_FILES[@]}"; do
    echo "Running benchmark with $query_file"
    ./run.sh "$query_file" 2>&1

    ./../result.sh "result.csv"
done