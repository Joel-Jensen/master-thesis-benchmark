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
        count++;
        # Store minimum time for each query (3 runs per query)
        query_idx = int((count - 1) / 3);
        run_in_query = (count - 1) % 3;
        # Only consider runs 2 and 3 (ignore first run)
        if (run_in_query > 0 && $1 < min_times[query_idx]) {
            min_times[query_idx] = $1;
        }
    }
    END { 
        num_queries = int(count / 3);
        # Calculate total based on minimum times
        for (i = 0; i < num_queries; i++) {
            total += min_times[i];
        }
        printf "Total runtime (sum of minimum times): %.0f ms\n", total;
        printf "Mean time per query: %.0f ms\n", total/num_queries;
        
        # Print minimum times array
        printf "Minimum times array: [";
        for (i = 0; i < num_queries; i++) {
            printf "%.0f", min_times[i];
            if (i < num_queries - 1) printf ",";
        }
        print "]";
        
        # Find query with highest minimum time
        max_min_time = 0;
        max_min_query = 0;
        for (i = 0; i < num_queries; i++) {
            if (min_times[i] > max_min_time) {
                max_min_time = min_times[i];
                max_min_query = i + 1;
            }
        }
        printf "Query with highest minimum time: Query %d (%.0f ms)\n", max_min_query, max_min_time;
    }'

echo -e "\n----------------------------------------\n"