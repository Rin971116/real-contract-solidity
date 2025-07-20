# Real Contract

A smart contract system for managing cases, voting, and compensation.

## Contract Addresses (Sepolia)

- RealContract: [0xe2637738db03dbdaed8853502bdd0d1fe95bcd11](https://sepolia.etherscan.io/address/0xe2637738db03dbdaed8853502bdd0d1fe95bcd11)
- Voter: [0x22dad1ada86e7e37aae2792055ab1c9c32fe2c16](https://sepolia.etherscan.io/address/0x22dad1ada86e7e37aae2792055ab1c9c32fe2c16)
- FakeERC20: [0x2f383a0b62f37e56ffc8dfc84a178f0324365b3e](https://sepolia.etherscan.io/address/0x2f383a0b62f37e56ffc8dfc84a178f0324365b3e)

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
