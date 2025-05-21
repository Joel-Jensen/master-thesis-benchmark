CREATE EXTENSION pg_mooncake;

CREATE TABLE transactions
(
    "id" BIGINT NOT NULL,
    "user_id" BIGINT NOT NULL,
    "amount" INT NOT NULL,
    "type" varchar(255) NOT NULL,
    "country_code" varchar(255) NOT NULL,
    "platform" varchar(255) NOT NULL,
    "created_at" timestamp(0) NOT NULL,
) USING columnstore;