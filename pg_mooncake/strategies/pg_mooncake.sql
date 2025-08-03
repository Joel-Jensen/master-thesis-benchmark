CREATE EXTENSION pg_mooncake;

-- Create regular rowstore table
CREATE TABLE transactions
(
    "id" BIGINT NOT NULL,
    "user_id" BIGINT NOT NULL,
    "amount" INT NOT NULL,
    "type" varchar(255) NOT NULL,
    "country_code" varchar(255) NOT NULL,
    "platform" varchar(255) NOT NULL,
    "created_at" timestamp(0) NOT NULL
);

-- Create columnstore mirror with separate name and URI
CALL mooncake.create_table('transactions_iceberg', 'transactions', 'postgresql://postgres:pg_mooncake@localhost:5433/test');