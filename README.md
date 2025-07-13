# Real Contract

A smart contract system for managing cases, voting, and compensation.

## Contract Addresses (Sepolia)

- RealContract: [0x99cD21960805a4A63D1F3694b6e8C30C59288f48](https://sepolia.etherscan.io/address/0x99cD21960805a4A63D1F3694b6e8C30C59288f48)
- Voter: [0x3f8214F002D93dFe584104122b7f6a72CF8fd498](https://sepolia.etherscan.io/address/0x3f8214F002D93dFe584104122b7f6a72CF8fd498)
- FakeERC20: [0xd9405d322951BF6a0185435B7A08525C0a32f219](https://sepolia.etherscan.io/address/0xd9405d322951BF6a0185435B7A08525C0a32f219)

## Participants

- Participant A: 0x565d490806A6D8eF532f4d29eC00EF6aAC71A17A
- Participant B: 0x8d521dCae9C1f7353a96D1510B3B4F9f83413bC9
- Deployer: 0xcafCE5363A2dEC41e0597B6B3c6c1A11ab219698

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
- Voting System: Secure voting mechanism with token-based validation
- Compensation System: Automated compensation distribution based on voting results

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

The system consists of three main contracts:

1. `RealContract`: Main contract handling case management and execution
2. `Voter`: Manages voter registration and validation
3. `FakeERC20`: ERC20 token for compensation and voting

## License

This project is licensed under the MIT License.
