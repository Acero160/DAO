# 🗳️ My First DAO – A Governance Smart Contract System

This project implements a complete on-chain governance system using Solidity and OpenZeppelin contracts. It includes a Governor, TimeLock, a custom ERC20 voting token, and a Box contract which is governed through proposals and votes.

## 📚 Overview

This decentralized autonomous organization (DAO) allows token holders to propose and vote on changes to a smart contract (Box), which stores a single number. It uses a timelock mechanism to delay execution of successful proposals, ensuring transparency and control.

## 🛠️ Contracts Included

### 1. **Box.sol**
A simple smart contract that stores a number. Only the owner (initially the DAO) can update it.

- `store(uint256 newNumber)`: Updates the stored number.
- `getNumber()`: Returns the current number.

### 2. **GovToken.sol**
An ERC20 token with voting capabilities.

- Based on OpenZeppelin's `ERC20Votes`.
- Includes `mint()` function to distribute voting power.

### 3. **TimeLock.sol**
A `TimelockController` contract that manages execution delays for proposals.

- Enforces a delay (`minDelay`) before approved proposals can be executed.
- Only authorized proposers and executors can interact.

### 4. **MyGovernor.sol**
A custom Governor contract that manages proposals, votes, and execution.

- Uses extensions: `GovernorSettings`, `GovernorCountingSimple`, `GovernorVotes`, `GovernorVotesQuorumFraction`, and `GovernorTimelockControl`.
- Parameters:
  - Voting delay: 1 block
  - Voting period: 50400 blocks (~1 week)
  - Quorum: 4% of total supply
  - Timelock delay: 1 hour

## ✅ Test Coverage

Tests are written using Foundry's testing framework. The key test covers the entire lifecycle of a DAO proposal:

- ✅ Fails when trying to directly change the Box without governance.
- ✅ Propose → Vote → Queue → Execute flow successfully updates the Box value.

### Example Test Flow

```solidity
1. Propose to store value in the Box.
2. Wait for voting delay and cast a vote.
3. Wait for voting period to end.
4. Queue the proposal in the Timelock.
5. Wait for Timelock delay and execute.
6. Assert Box value has been updated.
```
## 🔐 Roles & Security

- **`PROPOSER_ROLE`**: Assigned to the **Governor** contract  
- **`EXECUTOR_ROLE`**: Open to all (`address(0)`)  
- **`TIMELOCK_ADMIN_ROLE`**: Revoked to increase decentralization and security  

---

## 🧠 Learnings

This project taught me how to:

- ✅ Design and implement a DAO architecture  
- ✅ Use `ERC20Votes` for on-chain governance  
- ✅ Combine `TimeLock` and `Governor` patterns for proposal control  
- ✅ Write complete governance lifecycle tests (Propose → Vote → Queue → Execute)

