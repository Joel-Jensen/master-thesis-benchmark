#!/bin/bash

set -eux

threads=$(nproc)
cpus=$((threads > 1 ? threads / 2 : 1))

psql postgres://postgres:pg_mooncake@localhost:5433/postgres -t < create.sql

for chunk in ../split_10M/transactions_chunk_*
do
    #echo "Loading $chunk into database..."
    psql postgres://postgres:pg_mooncake@localhost:5433/postgres -t -c "\\copy transactions (id, user_id, amount, type, country_code, platform, created_at) FROM '$chunk' DELIMITER ','"
done
psql postgres://postgres:pg_mooncake@localhost:5433/postgres -t -c "\\copy users (id, name, email, email_verified_at, password, country_code, is_active, remember_token, created_at, updated_at) FROM '../users_10M.csv' DELIMITER ','"
#time psql postgres://postgres:pg_mooncake@localhost:5433/postgres -t <index.sql

# This is like VACUUM ANALYZE but for pg_mooncake
# time psql postgres://postgres:pg_mooncake@localhost:5433/postgres -t -c 'UPDATE transactions SET id=id'

./benchmark.sh