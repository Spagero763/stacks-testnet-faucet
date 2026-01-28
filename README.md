# Stacks Testnet Faucet

A Clarity smart contract faucet for the Stacks testnet that dispenses tSTX tokens.

## Overview

This faucet allows developers to claim free testnet STX tokens for testing and development purposes. Tokens have no real-world value and are only valid on the Stacks testnet.

## Features

- Claim 1 STX per request
- 24-hour cooldown between claims (~144 blocks)
- Check claim status before submitting transaction
- View faucet balance

## Contract Functions

### Public

- `claim` - Request tSTX from faucet (subject to cooldown)

### Read-only

- `get-claim-status` - Check if address can claim and blocks remaining
- `get-faucet-balance` - View current faucet balance
- `get-drip-amount` - Get amount dispensed per claim

## Development

```bash
# Check contract syntax
npm run check

# Run tests
npm test

# Open Clarinet console
npm run console
```

## Deployment

Deployed on Stacks testnet at: `ST26TQH4FRPTKHQEYE6HZQG98R4CZE6PTJ8J1YYR8.faucet`
