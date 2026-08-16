SELECT sender, receiver, amount, total_amount_thawing, thaw_end_timestamp, requested_at
FROM escrow_thaw_requests
ORDER BY requested_at DESC, sender, receiver
LIMIT 25;
