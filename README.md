# Graph TAP Escrow nest

An installable Nuthatch nest for legacy TAP Escrow activity on Arbitrum One. It replaces the event
surface of deployment `QmUhiH6Z5xo6o3GNzsSvqpGKLmCt6w5WzKQ1yHk6C8AA8S` without requiring a
hosted subgraph.

```sh
nuthatch init --from https://github.com/nightswatchhq/graph-tap-escrow-nest
nuthatch dev --dir graph-tap-escrow-nest --rpc https://your-archive-rpc
```

## Query surface

`escrow_movements` provides a normalised deposit, redeem, and withdrawal ledger.
`escrow_account_balances` folds those settled movements into exact token-base-unit balances.
`escrow_thaw_requests` and `escrow_signer_events` expose the two delayed state machines without
pretending that a thaw request is a withdrawal.

The contract is the legacy TAP Escrow at `0x8f477709eF277d4A880801D01A140a9CF88bA0d3`, from block
`159,124,376`. Its ABI is vendored. Fixed-block parity fixtures against the retired subgraph remain
the release gate before this is listed as available.
