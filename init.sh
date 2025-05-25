#!/bin/bash

wget --no-verbose --continue 'https://inly-master-thesis.ams3.digitaloceanspaces.com/transactions_1M.csv.gz'
gzip -d -f transactions_1M.csv.gz
sed -i '1d' transactions_1M.csv
mkdir -p split_1M
time split -l 100000 transactions_1M.csv split_1M/transactions_chunk_

wget --no-verbose --continue 'https://inly-master-thesis.ams3.digitaloceanspaces.com/transactions_10M.csv.gz'
gzip -d -f transactions_10M.csv.gz
sed -i '1d' transactions_10M.csv
mkdir -p split_10M
time split -l 100000 transactions_10M.csv split_10M/transactions_chunk_

wget --no-verbose --continue 'https://inly-master-thesis.ams3.digitaloceanspaces.com/users_10M.csv.gz'
gzip -d -f users_10M.csv.gz