SELECT
  event_type,
  COUNT(*) AS movement_count,
  MIN(block_number) AS first_block,
  MAX(block_number) AS last_block
FROM escrow_movements
GROUP BY event_type
ORDER BY event_type;
