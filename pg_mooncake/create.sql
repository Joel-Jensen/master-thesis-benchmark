CREATE EXTENSION pg_mooncake;
alter database postgres set mooncake.enable_memory_metadata_cache = true;
\timing
CREATE TABLE transactions
(
    "id" BIGINT PRIMARY KEY,
    "user_id" BIGINT NOT NULL,
    "amount" INT NOT NULL,
    "type" varchar(255) NOT NULL,
    "country_code" varchar(255) NOT NULL,
    "platform" varchar(255) NOT NULL,
    "created_at" timestamp(0) NOT NULL
) using columnstore;

CREATE TABLE users
(
    "id" BIGINT PRIMARY KEY,
    "name" varchar(255) NOT NULL,
    "email" varchar(255) NOT NULL,
    "email_verified_at" timestamp(0),
    "password" varchar(255) NOT NULL,
    "country_code" varchar(255) NOT NULL,
    "is_active" BOOLEAN NOT NULL,
    "remember_token" varchar(100),
    "created_at" timestamp(0) NOT NULL,
    "updated_at" timestamp(0) NOT NULL
);

