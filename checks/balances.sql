SELECT sender, receiver, balance, movement_count, last_activity_at
FROM escrow_account_balances
ORDER BY CAST(balance AS DECIMAL(38, 0)) DESC, sender, receiver
LIMIT 25;
