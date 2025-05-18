#!/bin/bash

QUERY_FILE=${1:-queries.sql}

echo "Results for $QUERY_FILE:"
cat "log_${QUERY_FILE%.sql}.txt" | grep -oP 'Time: \d+\.\d+ ms' | sed -r -e 's/Time: ([0-9]+\.[0-9]+) ms/\1/' |
    awk '{ if (i % 3 == 0) { printf "[" }; printf $1 / 1000; if (i % 3 != 2) { printf "," } else { print "]," }; ++i; }'

# Calculate total, mean runtime statistics, and find the query with highest minimum time
echo -e "\nRuntime Statistics for $QUERY_FILE:"
cat "log_${QUERY_FILE%.sql}.txt" | grep -oP 'Time: \d+\.\d+ ms' | sed -r -e 's/Time: ([0-9]+\.[0-9]+) ms/\1/' |
    awk '
    BEGIN { 
        total = 0; 
        count = 0;
        # Initialize with a large array size, we will track the actual number of queries
        for (i = 0; i < 100; i++) {
            min_times[i] = 999999;
        }
    }
    { 
        total += $1; 
        count++;
        # Store minimum time for each query (3 runs per query)
        query_idx = int((count - 1) / 3);
        if ($1 < min_times[query_idx]) {
            min_times[query_idx] = $1;
        }
    }
    END { 
        num_queries = int(count / 3);
        printf "Total runtime: %.3f ms\n", total;
        printf "Mean time per query: %.3f ms\n", total/count;
        
        # Find query with highest minimum time
        max_min_time = 0;
        max_min_query = 0;
        for (i = 0; i < num_queries; i++) {
            if (min_times[i] > max_min_time) {
                max_min_time = min_times[i];
                max_min_query = i + 1;
            }
        }
        printf "Query with highest minimum time: Query %d (%.3f ms)\n", max_min_query, max_min_time;
    }'

echo -e "\n----------------------------------------\n"