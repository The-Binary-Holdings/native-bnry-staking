# Staking Contract

## Overview
The Staking Contract allows users to stake BNRY tokens and earn rewards over time. The contract manages the staking process, including depositing and withdrawing tokens, and ensures secure and efficient operations.

## Features
- **Staking:** Users can deposit BNRY tokens into the contract.
- **Withdrawals:** Users can withdraw their staked tokens at any time.
- **Security:** The contract uses OpenZeppelin’s `ReentrancyGuard` to prevent reentrancy attacks.

## Requirements
- **Solidity Version:** 0.8.25
- **BNRY Token:** The contract is designed to work with BNRY tokens as the native currency.

### Setup
1. Clone the repository:
   ```bash
   git clone <repo-link>

2. Install the necessary dependencies :
   ```bash
   npm i 

3.Compile and test Contracts
   ```bash
   npx hardhat compile
   npx hardhat test
