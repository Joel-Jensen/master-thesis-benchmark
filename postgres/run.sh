#!/bin/bash

TRIES=3
QUERY_FILE=${1:-queries.sql}

cat "$QUERY_FILE" | while read -r query; do
    sync
    sudo tee /proc/sys/vm/drop_caches >/dev/null <<< "3"

    echo "$query"
    (
        echo '\timing'
        yes "$query" | head -n $TRIES
    ) | sudo -u postgres psql test -t | grep 'Time'
    echo "----------------------------------------"
done