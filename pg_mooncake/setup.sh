#!/bin/bash

set -eux

psql postgres://postgres:pg_mooncake@localhost:5433/postgres -t -c 'DROP DATABASE test WITH (FORCE)'
psql postgres://postgres:pg_mooncake@localhost:5433/postgres -t -c 'CREATE DATABASE test'
psql postgres://postgres:pg_mooncake@localhost:5433/postgres test -t < create.sql

threads=$(nproc)
cpus=$((threads > 1 ? threads / 2 : 1))

# Using COPY with explicit column mapping to ensure correct alignment.
for chunk in ../split_10M/transactions_chunk_*
do
    #echo "Loading $chunk into database..."
    psql postgres://postgres:pg_mooncake@localhost:5433/postgres -c "\\copy transactions (id, user_id, amount, type, country_code, platform, created_at) FROM '$chunk' DELIMITER ','"
done
psql postgres://postgres:pg_mooncake@localhost:5433/postgres -c "\\copy users (id, name, email, email_verified_at, password, country_code, is_active, remember_token, created_at, updated_at) FROM '../users_10M.csv' DELIMITER ','"
#time psql postgres://postgres:pg_mooncake@localhost:5433/postgres -t <index.sql

time psql postgres://postgres:pg_mooncake@localhost:5433/postgres -t -c 'VACUUM ANALYZE transactions'

./benchmark.sh