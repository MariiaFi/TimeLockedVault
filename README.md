# TimeLockedVault

> Multi-role vault smart contract for time-locked deposits and controlled withdrawals.

## Overview

**TimeLockedVault** is a Solidity smart contract that enables:
- Secure deposits with time locks (delayed withdrawals).
- Maintaining deposit history for each user.
- Multi-role access control (`Owner`, `Admin`, `User`).
- Restricting function calls to specific roles.
- Transparent event logs for deposits, withdrawals, and role assignments.

This contract is designed for projects requiring structured access control and time-locked fund management.

---

## Roles

The contract defines an `enum Role`:

- `None` — default role.
- `User` — allowed to deposit and withdraw.
- `Admin` — allowed to assign roles.
- `Owner` — the contract owner, set in the constructor.

---

## Deployment

When you deploy the contract, the deployer becomes the **Owner** and **Admin**.

```solidity
constructor() {
    owner = msg.sender;
    roles[msg.sender] = Role.Admin;
}
```

---

## Functions

```
+-----------------------------+--------+--------------------------------------------+
| Function                    | Access | Description                                |
+-----------------------------+--------+--------------------------------------------+
| setRole(address, Role)      | Admin  | Assign or change a user’s role.            |
| deposit(uint256)            | User   | Deposit ETH locked for a specific period.  |
| withdraw(uint256)           | User   | Withdraw funds after the unlock time.      |
| getDeposits(address)        | Public | Retrieve the array of user deposits.       |
+-----------------------------+--------+--------------------------------------------+
```

---

## Usage Example

**Assign a role:**

```solidity
setRole(0xUserAddress, Role.User);
```

**Deposit ETH locked for 1 day:**

```solidity
deposit(86400); // 86400 seconds = 24 hours
```

**Withdraw the first deposit:**

```solidity
withdraw(0); // Index of the deposit in the array
```

---

## Events

The contract emits the following events:

- `DepositCreated(address user, uint256 amount, uint256 unlockTime)`
- `Withdrawal(address user, uint256 amount)`
- `RoleChanged(address user, Role newRole)`

---

## Extending

Potential improvements:

- Add penalties for early withdrawal.
- Support ERC20 tokens.
- Integrate Chainlink oracles for timestamp verification.
- Implement multisig for admin operations.

---

## License

MIT License © 2025 https://www.linkedin.com/in/mariia-fialkovska-78857b234/