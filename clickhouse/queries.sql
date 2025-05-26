SELECT COUNT(DISTINCT user_id) AS distinct_user_count FROM transactions;
SELECT id, user_id, amount, type, country_code, created_at FROM transactions ORDER BY amount DESC LIMIT 10;
SELECT COUNT(*) AS transactions_above_average FROM transactions WHERE amount > (SELECT AVG(amount) FROM transactions);
SELECT user_id, COUNT(*) AS transaction_count, SUM(amount) AS total_amount FROM transactions WHERE user_id IN (1000, 2000, 3000, 4000, 5000, 6000, 7000, 8000, 9000, 10000) GROUP BY user_id ORDER BY transaction_count DESC;
SELECT type, COUNT(*) AS transaction_count, SUM(amount) AS total_amount FROM transactions GROUP BY type ORDER BY transaction_count DESC;
SELECT user_id, COUNT(*) AS transaction_count, SUM(amount) AS total_amount, AVG(amount) AS average_amount FROM transactions GROUP BY user_id ORDER BY total_amount DESC LIMIT 10;
SELECT toHour(created_at) AS transaction_hour, type, COUNT(*) AS transaction_count FROM transactions GROUP BY toHour(created_at), type ORDER BY transaction_hour, transaction_count DESC LIMIT 5;
WITH RankedUsers AS ( SELECT user_id, SUM(amount) AS total_amount, RANK() OVER (ORDER BY SUM(amount) DESC) AS user_rank FROM transactions GROUP BY user_id ), Top10Users AS ( SELECT user_id FROM RankedUsers WHERE user_rank <= 10 ), RankedTransactions AS ( SELECT t.user_id, t.id, t.amount, ROW_NUMBER() OVER (PARTITION BY t.user_id ORDER BY t.amount DESC) AS transaction_rank FROM transactions t JOIN Top10Users u ON t.user_id = u.user_id ) SELECT user_id, id, amount FROM RankedTransactions WHERE transaction_rank <= 10 ORDER BY user_id, amount DESC;
SELECT t.user_id, COUNT(*) AS transaction_count, SUM(t.amount) AS total_amount FROM transactions t JOIN users u ON t.user_id = u.id WHERE u.is_active = true GROUP BY t.user_id ORDER BY total_amount DESC;
