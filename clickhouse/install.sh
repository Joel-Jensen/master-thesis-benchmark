#!/bin/bash

# Install

if [ ! -x /usr/bin/clickhouse ]
then
    curl https://clickhouse.com/ | sh
    sudo ./clickhouse install --noninteractive
fi

# Optional: if you want to use higher compression:
if (( 0 )); then
    echo "
compression:
    case:
        method: zstd
    " | sudo tee /etc/clickhouse-server/config.d/compression.yaml
fi;

sudo clickhouse start

while true
do
    clickhouse-client --query "SELECT 1" && break
    sleep 1
done


# Load the data

clickhouse-client < create.sql

clickhouse-client --time --query "TRUNCATE TABLE transactions"
clickhouse-client --time --query "INSERT INTO transactions FORMAT CSV" < ../transactions_10M.csv

# Run the queries

./run.sh

clickhouse-client --query "SELECT total_bytes FROM system.tables WHERE name = 'transactions' AND database = 'default'"