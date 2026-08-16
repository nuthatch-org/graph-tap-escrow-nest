CREATE VIEW escrow_thaw_requests AS
WITH latest_thaw AS (
  SELECT *, ROW_NUMBER() OVER (
    PARTITION BY sender, receiver ORDER BY block_number DESC, log_index DESC
  ) AS row_number
  FROM escrow__thaw
), latest_cancel AS (
  SELECT sender, receiver, block_number, log_index
  FROM escrow__cancel_thaw
)
SELECT
  thaw.sender,
  thaw.receiver,
  thaw.amount_dec::VARCHAR AS amount,
  thaw."totalAmountThawing_dec"::VARCHAR AS total_amount_thawing,
  thaw."thawEndTimestamp_dec"::VARCHAR AS thaw_end_timestamp,
  thaw.block_timestamp AS requested_at,
  thaw.tx_hash
FROM latest_thaw thaw
WHERE thaw.row_number = 1
  AND NOT EXISTS (
    SELECT 1 FROM latest_cancel cancellation
    WHERE cancellation.sender = thaw.sender
      AND cancellation.receiver = thaw.receiver
      AND (cancellation.block_number > thaw.block_number
        OR (cancellation.block_number = thaw.block_number AND cancellation.log_index > thaw.log_index))
  );

-- Expose signer state transitions without concealing time-delayed removal semantics.
CREATE VIEW escrow_signer_events AS
SELECT tx_hash || '-' || CAST(log_index AS VARCHAR) AS id, 'authorised' AS event_type,
  sender, signer AS authorised_signer, NULL::VARCHAR AS thaw_end_timestamp, block_timestamp, tx_hash
FROM escrow__authorize_signer
UNION ALL
SELECT tx_hash || '-' || CAST(log_index AS VARCHAR), 'revoked', sender, "authorizedSigner", NULL::VARCHAR, block_timestamp, tx_hash
FROM escrow__revoke_authorized_signer
UNION ALL
SELECT tx_hash || '-' || CAST(log_index AS VARCHAR), 'thaw_requested', sender, "authorizedSigner", "thawEndTimestamp_dec"::VARCHAR, block_timestamp, tx_hash
FROM escrow__thaw_signer
UNION ALL
SELECT tx_hash || '-' || CAST(log_index AS VARCHAR), 'thaw_cancelled', sender, "authorizedSigner", "thawEndTimestamp_dec"::VARCHAR, block_timestamp, tx_hash
FROM escrow__cancel_thaw_signer;
