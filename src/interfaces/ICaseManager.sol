// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

interface ICaseManager {
    enum CaseStatus {
        //未啟動
        Inactivated,
        //啟動
        Activated,
        //投票中
        Voting,
        //放棄
        Abandoned,
        //已執行
        Executed
    }

    // 實際儲存的物件(用於儲存案件資訊)
    struct Case {
        // 案件編號
        uint256 caseNum;
        // 案件名稱
        string caseName;
        // 案件描述
        string caseDescription;
        // 參與者地址
        address participantA;
        address participantB;
        // 需存入之金額
        uint256 compensationA;
        uint256 compensationB;
        // 實際支付金額
        uint256 existingCompensationA;
        uint256 existingCompensationB;
        // 是否已支付
        bool isPaidA;
        bool isPaidB;
        // 是否已執行
        bool isExecuted;
        // 勝者
        address winner;
        // 狀態
        CaseStatus status;
        // 投票開始時間
        uint256 votingStartTime;
        // voting duration
        uint256 votingDuration;
        // 已投票者
        mapping(address => bool) voterIsVoted;
        // 投票者
        address[] voters;
        // 紀錄得票數
        mapping(address => uint256) voterVotes;
        // 投票獎池
        uint256 votePool;
        // 分配模式(0: 勝者全拿, 1: 按得票數比例分配)
        uint256 allocationMode;
    }

    // 請求時用的物件(用於初始化案件)
    struct CaseInit {
        // 案件名稱
        string caseName;
        // 案件描述
        string caseDescription;
        // 參與者地址
        address participantA;
        address participantB;
        // 賠償金額
        uint256 compensationA;
        uint256 compensationB;
        // voting duration
        uint256 votingDuration;
        // 分配模式(0: 勝者全拿, 1: 按得票數比例分配)
        uint256 allocationMode;
    }

    struct CaseResult {
        // 案件編號
        uint256 caseNum;
        // 案件狀態
        CaseStatus caseStatus;
        // 勝者
        address currentWinner;
        // 需存入之金額
        uint256 compensationA;
        uint256 compensationB;
        // 已存入之金額
        uint256 existingCompensationA;
        uint256 existingCompensationB;
        // 得票數A
        uint256 voteCountA;
        // 得票數B
        uint256 voteCountB;
        // 是否結束投票
        bool voteEnded;
        // 分配模式(0: 勝者全拿, 1: 按得票數比例分配)
        uint256 allocationMode;
    }

    struct CancelCaseRequest {
        uint256 caseNum;
        uint8 approveCount;
        mapping(address => bool) approved;
    }

    // external代表這個函數是給外部呼叫的
    // view代表這個函數不會修改合約狀態，只會讀取合約狀態
    // returns (CaseStatus)代表這個函數回傳一個CaseStatus枚舉
    function getCaseStatus(uint256 caseNum) external view returns (CaseStatus);

    function getCaseDescription(uint256 caseNum) external view returns (string memory);

    function getCaseCompensationA(uint256 caseNum) external view returns (uint256);

    function getCaseCompensationB(uint256 caseNum) external view returns (uint256);

    function getCaseWinner(uint256 caseNum) external view returns (address);

    function getCaseVotingDuration(uint256 caseNum) external view returns (uint256);

    function getCaseVotersCount(uint256 caseNum) external view returns (uint256);

    function getCaseVoterVotes(uint256 caseNum, address voter) external view returns (uint256);

    function getCaseIsPaidA(uint256 caseNum) external view returns (bool);
}
