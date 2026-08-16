-- A single account-facing ledger. `balance_delta` is token base units as text so values retain
-- exact uint256 precision. The raw escrow__* tables remain the source of truth.
CREATE VIEW escrow_movements AS
SELECT
  tx_hash || '-' || CAST(log_index AS VARCHAR) AS id,
  'deposit' AS event_type,
  sender,
  receiver,
  NULL::VARCHAR AS allocation_id,
  amount_dec::VARCHAR AS amount,
  amount_dec::VARCHAR AS balance_delta,
  block_number,
  block_timestamp AS timestamp,
  tx_hash
FROM escrow__deposit
UNION ALL
SELECT
  tx_hash || '-' || CAST(log_index AS VARCHAR),
  'redeem',
  sender,
  receiver,
  "allocationID",
  "actualAmount_dec"::VARCHAR,
  '-' || "actualAmount_dec"::VARCHAR,
  block_number,
  block_timestamp,
  tx_hash
FROM escrow__redeem
UNION ALL
SELECT
  tx_hash || '-' || CAST(log_index AS VARCHAR),
  'withdraw',
  sender,
  receiver,
  NULL::VARCHAR,
  amount_dec::VARCHAR,
  '-' || amount_dec::VARCHAR,
  block_number,
  block_timestamp,
  tx_hash
FROM escrow__withdraw;

-- Funds remain in escrow while thawing. Only a Withdraw event settles that deduction.
CREATE VIEW escrow_account_balances AS
SELECT
  sender,
  receiver,
  SUM(CAST(balance_delta AS DECIMAL(38, 0)))::VARCHAR AS balance,
  COUNT(*) AS movement_count,
  MAX(timestamp) AS last_activity_at
FROM escrow_movements
GROUP BY sender, receiver;
