// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

interface IRealContract {
    // 案件相關事件
    event CaseAdded(
        uint256 indexed caseNum,
        string caseName,
        string caseDescription
    );
    event CaseStaked(
        uint256 indexed caseNum,
        address indexed participant,
        uint256 amount
    );
    event CaseVoted(
        uint256 indexed caseNum,
        address indexed voter,
        address indexed voteFor
    );
    event CaseExecuted(uint256 indexed caseNum, address indexed winner);
    event CaseRolledBack(uint256 indexed caseNum);

    // 合約狀態事件
    event ContractStatusChanged(bool running);
    event FeeRateUpdated(
        uint256 stakeCompensationFeeRate,
        uint256 executeCaseFeeRate
    );

    // 案件投票事件
    event CaseVotingStarted(uint256 indexed caseNum);

    // 案件取消事件
    event CaseCancelled(uint256 indexed caseNum);

    // 錯誤事件
    event CaseError(uint256 indexed caseNum, string reason);
}
