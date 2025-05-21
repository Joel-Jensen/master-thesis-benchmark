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

CREATE INDEX user_id on transactions (user_id);
CREATE INDEX type on transactions (type);
CREATE INDEX created_at on transactions (created_at);