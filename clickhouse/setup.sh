clickhouse-client < create.sql

clickhouse-client --time --query "TRUNCATE TABLE transactions"
clickhouse-client --time --query "INSERT INTO transactions FORMAT CSV" < ../transactions_10M.csv

clickhouse-client --time --query "TRUNCATE TABLE users"
clickhouse-client --time --query "INSERT INTO users FORMAT CSV" < ../users_10M.csv

clickhouse-client --query "SELECT total_bytes FROM system.tables WHERE name = 'transactions' AND database = 'default'"

./benchmark.sh