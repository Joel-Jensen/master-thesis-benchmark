#!/bin/bash

set -eux

# Check if strategy parameter is provided
if [ $# -eq 0 ]; then
    echo "Usage: $0 <strategy>"
    exit 1
fi

STRATEGY=$1

sudo -u postgres psql -t -c 'DROP DATABASE test WITH (FORCE)'
sudo -u postgres psql -t -c 'CREATE DATABASE test'
sudo -u postgres psql test -t < strategies/$STRATEGY.sql

threads=$(nproc)
cpus=$((threads > 1 ? threads / 2 : 1))

# Using COPY with explicit column mapping to ensure correct alignment.
for chunk in ../split_1M/transactions_chunk_*
do
    #echo "Loading $chunk into database..."
    sudo -u postgres psql test -c "\\copy transactions (id, user_id, amount, type, country_code, platform, created_at) FROM '$chunk' DELIMITER ','"
done
sudo -u postgres psql test -c "\\copy users (id, name, email, email_verified_at, password, country_code, is_active, remember_token) FROM '../users_10M.csv' DELIMITER ','"
#time sudo -u postgres psql test -t <index.sql

time sudo -u postgres psql test -t -c 'VACUUM ANALYZE transactions'

./benchmark.sh