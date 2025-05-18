#!/bin/bash

#set -eux

threads=$(nproc)
cpus=$((threads > 1 ? threads / 2 : 1))

# Using COPY with explicit column mapping to ensure correct alignment.
time split transactions_1M.csv split/transactions_chunk_
for chunk in split/transactions_chunk_*
do
    #echo "Loading $chunk into database..."
    sudo -u postgres psql test -c "\\copy transactions (id, user_id, amount, type, country_code, platform, created_at) FROM '$chunk' DELIMITER ',' CSV HEADER"
done
#time sudo -u postgres psql test -t <index.sql

time sudo -u postgres psql test -t -c 'VACUUM ANALYZE transactions'