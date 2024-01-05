# DAO

This project is a Solidity-based implementation of a DAO. It includes a custom governor contract (MyGovernor), a governance token (GovToken), a timelock contract (Timelock), targeted contract that used to demonstrate governance (Box), and a contract for testing (MyGovernorTest).

## Contracts

### MyGovernor

This contract is the core of the governance system. It interacts with the GovToken and Timelock contracts to manage proposals, voting, and execution of changes.

### GovToken

This is a token contract that follows the ERC20 standard. It is used in the governance system to represent voting power.

### Timelock

This contract is used to enforce a delay between the time a proposal is made and the time it can be executed. This gives token holders time to vote on the proposal.

### Box

The `Box` contract is a simple Solidity contract that allows for storing and retrieving a number. It uses the `Ownable` contract from the OpenZeppelin library, which provides basic access control mechanisms.

### MyGovernorTest

This contract is used for testing the functionality of the MyGovernor contract. It sets up a test environment and includes various test cases.

## Setup

To set up the test environment, the `setUp` function is called. This function does the following:

- Creates a new GovToken contract and mints some tokens to a user.
- Sets the user as the delegate for voting.
- Creates a new Timelock contract with a minimum delay and lists of proposers and executors.
- Creates a new MyGovernor contract with the GovToken and Timelock contracts as parameters.
- Grants the MyGovernor contract the role of proposer in the Timelock contract.

## Testing

Run this command for testing:
```bash
forge test
```

