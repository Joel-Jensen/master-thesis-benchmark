CREATE TABLE transactions
(
    "id" BIGINT PRIMARY KEY,
    "user_id" BIGINT NOT NULL,
    "amount" INT NOT NULL,
    "type" varchar(255) NOT NULL,
    "country_code" varchar(255) NOT NULL,
    "platform" varchar(255) NOT NULL,
    "created_at" timestamp(0) NOT NULL
);

SELECT create_hypertable('transactions', 'created_at', by_range('time', INTERVAL '3 months'));