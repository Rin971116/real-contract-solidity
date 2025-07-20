// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "../src/RealContract.sol";
import "../src/Voter.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MockERC20 is ERC20 {
    constructor(string memory name, string memory symbol) ERC20(name, symbol) {
        _mint(msg.sender, 1000000000000000 * 10 ** 18);
    }
}

contract DeployScript is Script {
    function run() public {
        // 從環境變數讀取私鑰
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployer = vm.addr(deployerPrivateKey);
        console.log("Deployer address:", deployer);

        // 開始廣播交易
        vm.startBroadcast(deployerPrivateKey);

        // 部署假的ERC20(保證金用測試幣)
        MockERC20 fakeERC20 = new MockERC20("FakeERC20", "FERC20");
        console.log("FakeERC20 deployed to:", address(fakeERC20));

        // 部署投票用代幣
        MockERC20 voteToken = new MockERC20("VoteToken", "VT");
        console.log("VoteToken deployed to:", address(voteToken));

        // 部署 Voter 合約
        Voter voter = new Voter(deployer);
        console.log("Voter deployed to:", address(voter));

        // 部署 RealContract 合約
        RealContract realContract = new RealContract(
            deployer, // governance
            address(voter), // voter
            address(fakeERC20), // compensationToken
            address(voteToken), // voteToken
            100, // feeRateForStakeCompensation (1%)
            200, // feeRateForExecuteCase (2%)
            100 * 10 ** 18 // 100顆 vote tokens
        );
        console.log("RealContract deployed to:", address(realContract));

        // 添加投票者 測試錢包
        address testVoter = address(0x20Db3FD960194551325eBC1145562aEBdbD99F1a);
        voter.addVoter(testVoter);
        console.log("Added testVoter as voter");

        // 添加投票者 部署者錢包
        voter.addVoter(deployer);
        console.log("Added deployer as voter");

        // 設定兩個測試錢包地址
        address testParticipantA = address(0x57a0cd579B0fb24f3282F69680eeE85E3e5bCD68);
        address testParticipantB = address(0x137C941D1097488cc9B454c362c768B7A837DA22);

        // 轉移測試幣給測試錢包
        fakeERC20.transfer(testParticipantA, 10000000 * 10 ** 18);
        fakeERC20.transfer(testParticipantB, 10000000 * 10 ** 18);
        console.log("Transferred fakeERC20 tokens to test participants");

        // 轉移投票代幣給測試錢包
        voteToken.transfer(testVoter, 10000000 * 10 ** 18);
        console.log("Transferred vote tokens to testVoter");

        // 轉移兩種測試幣給 部署者錢包
        fakeERC20.transfer(deployer, 10000000 * 10 ** 18);
        voteToken.transfer(deployer, 10000000 * 10 ** 18);
        console.log("Transferred both tokens to deployer (your wallet)");

        // 停止廣播交易
        vm.stopBroadcast();

        // 打印部署摘要
        console.log("\n=== Deployment Summary ===");
        console.log("Network: Sepolia");
        console.log("Deployer:", deployer);
        console.log("\nContract Addresses:");
        console.log("FakeERC20:", address(fakeERC20));
        console.log("VoteToken:", address(voteToken));
        console.log("Voter:", address(voter));
        console.log("RealContract:", address(realContract));
        console.log("\nParticipants:");
        console.log("Test Participant A:", testParticipantA);
        console.log("Test Participant B:", testParticipantB);
        console.log("\nToken Balances:");
        console.log("Example Participant A Balance:", fakeERC20.balanceOf(testParticipantA));
        console.log("Example Participant B Balance:", fakeERC20.balanceOf(testParticipantB));
        console.log("Deployer Balance:", fakeERC20.balanceOf(deployer));
        console.log("\nContract Parameters:");
        console.log("Fee Rate for Stake Compensation: 1%");
        console.log("Fee Rate for Execute Case: 2%");
        console.log("Stake Amount: 100 wei");
        console.log("\nNext Steps:");
        console.log("1. Use the provided test participants to create cases");
        console.log("2. Add participants as voters (if needed)");
        console.log("3. Start testing case creation and voting");
        console.log("========================\n");
    }
}
