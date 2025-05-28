#!/bin/bash

TRIES=3
CONNECTION=postgres://postgres:pg_mooncake@localhost:5433/postgres
QUERY_FILE=${1:-queries.sql}

cat "$QUERY_FILE" | while read -r query; do
    sync
    echo 3 | sudo tee /proc/sys/vm/drop_caches

    echo "$query"
    (
        echo '\timing'
        yes "$query" | head -n $TRIES
    ) | psql $CONNECTION | grep 'Time'
done