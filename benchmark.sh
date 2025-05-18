#!/bin/bash

set -eux

PGVERSION=17

./run.sh 2>&1 | tee log.txt

sudo du -bcs /var/lib/postgresql/$PGVERSION/main/

cat log.txt | grep -oP 'Time: \d+\.\d+ ms' | sed -r -e 's/Time: ([0-9]+\.[0-9]+) ms/\1/' |
    awk '{ if (i % 3 == 0) { printf "[" }; printf $1 / 1000; if (i % 3 != 2) { printf "," } else { print "]," }; ++i; }'

# Calculate total and mean runtime statistics
echo -e "\nRuntime Statistics:"
cat log.txt | grep -oP 'Time: \d+\.\d+ ms' | sed -r -e 's/Time: ([0-9]+\.[0-9]+) ms/\1/' |
    awk '
    BEGIN { total = 0; count = 0; }
    { total += $1; count++; }
    END { 
        printf "Total runtime: %.3f ms\n", total;
        printf "Mean time per query: %.3f ms\n", total/count;
    }'