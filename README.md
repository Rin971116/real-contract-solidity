# Real Contract

A smart contract system for managing cases, voting, and compensation.

## Contract Addresses (Sepolia)

- RealContract: [0x7166b5aCE489950b7b89A6A4060290dD5Ec4eB31](https://sepolia.etherscan.io/address/0x7166b5aCE489950b7b89A6A4060290dD5Ec4eB31)
- Voter: [0xE107c25a6939274Db7a3c10a6d0b75A700bA5cf2](https://sepolia.etherscan.io/address/0xE107c25a6939274Db7a3c10a6d0b75A700bA5cf2)
- FakeERC20: [0xDdDd56A2028705e11Ab2c7C853387d560c134BD9](https://sepolia.etherscan.io/address/0xDdDd56A2028705e11Ab2c7C853387d560c134BD9)
- VoteToken: [0x7AAB8e06E9BbCC3265D5f3225995c60a24aD0a62](https://sepolia.etherscan.io/address/0x7AAB8e06E9BbCC3265D5f3225995c60a24aD0a62)

## Participants

- Test Participant A: 0x57a0cd579B0fb24f3282F69680eeE85E3e5bCD68
- Test Participant B: 0x137C941D1097488cc9B454c362c768B7A837DA22
- Deployer: 0xBB4d7e4e3d0b3927f2829d6BE1D16B6D6fe63fA3

## Token Balances

- Participant A: 10,000,000 tokens
- Participant B: 10,000,000 tokens
- Deployer: 999,999,980,000,000 tokens

## Contract Parameters

- Fee Rate for Stake Compensation: 1%
- Fee Rate for Execute Case: 2%
- Stake Amount: 100 wei

## Features

- Case Management: Create, stake, and execute cases
- Voting System: Secure voting mechanism with separate voting tokens
- Compensation System: Automated compensation distribution using FakeERC20 tokens

## Development Setup

1. Install dependencies:
```bash
forge install
```

2. Compile contracts:
```bash
forge build
```

3. Run tests:
```bash
forge test
```

4. Deploy to Sepolia:
```bash
forge script script/Deploy.s.sol:Deploy --rpc-url $SEPOLIA_RPC_URL --broadcast --verify
```

## Contract Architecture

The system consists of four main contracts:

1. `RealContract`: Main contract handling case management and execution
2. `Voter`: Manages voter registration and validation
3. `FakeERC20`: ERC20 token for compensation
4. `VoteToken`: ERC20 token for voting rights

## License

This project is licensed under the MIT License.
