// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "./interfaces/ICaseManager.sol";
import "./Governance.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

// abstract 表示這個合約不能直接部署，只能再被其他合約繼承
abstract contract CaseManager is Governance, ICaseManager {
    // 使用 SafeERC20 庫來安全地操作 ERC20 代幣
    // 這是一個 OpenZeppelin 提供的安全代幣操作庫
    using SafeERC20 for IERC20;

    uint256 public currentCaseNum;

    mapping(uint256 => ICaseManager.Case) public cases;

    mapping(uint256 => ICaseManager.CancelCaseRequest) public cancelCaseRequests;

    // 添加案件
    function addCases(ICaseManager.CaseInit[] calldata _cases) public virtual {
        for (uint256 i = 0; i < _cases.length; i++) {
            _addCase(_cases[i]);
        }
    }

    // 添加案件 calldata代表唯讀不能改，跟memory不同 ; virtual表示可以被override
    function addCase(ICaseManager.CaseInit calldata _case) public virtual {
        _addCase(_case);
    }

    function _addCase(ICaseManager.CaseInit calldata _case) internal virtual {
        // 檢查參與者地址不能為零地址
        require(_case.participantA != address(0), "Participant A cannot be zero address");
        require(_case.participantB != address(0), "Participant B cannot be zero address");
        require(_case.participantA != _case.participantB, "Participants cannot be the same");
        require(_case.compensationA > 0 || _case.compensationB > 0, "Compensation must be greater than 0");
        require(_case.votingDuration > 0, "Voting duration must be greater than 0");
        require(_case.allocationMode <= 1 || _case.allocationMode >= 0, "Invalid allocation mode");

        ICaseManager.Case storage newCase = cases[currentCaseNum];
        newCase.caseNum = currentCaseNum;
        newCase.caseName = _case.caseName;
        newCase.caseDescription = _case.caseDescription;
        newCase.participantA = _case.participantA;
        newCase.participantB = _case.participantB;
        newCase.compensationA = _case.compensationA;
        newCase.compensationB = _case.compensationB;
        newCase.isPaidA = false;
        if (_case.compensationA == 0) {
            newCase.isPaidA = true;
        }
        newCase.isPaidB = false;
        if (_case.compensationB == 0) {
            newCase.isPaidB = true;
        }
        newCase.votingDuration = _case.votingDuration;
        newCase.allocationMode = _case.allocationMode;
        newCase.status = CaseStatus.Inactivated;
        currentCaseNum++;
    }

    // 更新案件狀態
    function _updateCaseStatus(uint256 _caseNum, CaseStatus _status) internal {
        cases[_caseNum].status = _status;
    }

    // 投票結果
    function _getCaseResult(uint256 _caseNum) internal view returns (CaseResult memory) {
        require(
            cases[_caseNum].status == CaseStatus.Voting || cases[_caseNum].status == CaseStatus.Executed,
            "Case is not voting or executed"
        );

        ICaseManager.Case storage _case = cases[_caseNum];
        CaseResult memory caseResult;
        caseResult.caseNum = _case.caseNum;
        caseResult.compensationA = _case.compensationA;
        caseResult.compensationB = _case.compensationB;
        caseResult.existingCompensationA = _case.existingCompensationA;
        caseResult.existingCompensationB = _case.existingCompensationB;
        caseResult.caseStatus = _case.status;
        caseResult.voteCountA = _case.numberOfVotes[_case.participantA];
        caseResult.voteCountB = _case.numberOfVotes[_case.participantB];
        caseResult.allocationMode = _case.allocationMode;
        caseResult.voteEnded = _case.votingDuration + _case.votingStartTime < block.timestamp;
        caseResult.voteChoice = _case.voterChoice[msg.sender];
        caseResult.voterHasClaimed = _case.voterHasClaimed[msg.sender];

        if (caseResult.voteCountA > caseResult.voteCountB) {
            caseResult.currentWinner = _case.participantA;
        } else if (caseResult.voteCountA < caseResult.voteCountB) {
            caseResult.currentWinner = _case.participantB;
        } else {
            // 表示平手
            caseResult.currentWinner = address(0);
        }

        return caseResult;
    }

    // 存入保證金
    function _stakeCompensation(uint256 _caseNum, IERC20 _compensationToken, bool _payA, uint256 _amount) internal {
        require(cases[_caseNum].status == CaseStatus.Activated || 
                cases[_caseNum].status == CaseStatus.Inactivated, "Case is not activated or inactivated");
        if (_payA) {
            cases[_caseNum].existingCompensationA += _amount;
            if (cases[_caseNum].existingCompensationA >= cases[_caseNum].compensationA) {
            cases[_caseNum].isPaidA = true;
            } 
        } else {
            cases[_caseNum].existingCompensationB += _amount;
            if (cases[_caseNum].existingCompensationB >= cases[_caseNum].compensationB) {
                cases[_caseNum].isPaidB = true;
            } 
        }
        
        _compensationToken.safeTransferFrom(msg.sender, address(this), _amount);

        if (cases[_caseNum].status == CaseStatus.Inactivated && cases[_caseNum].isPaidA && cases[_caseNum].isPaidB) {
            _updateCaseStatus(_caseNum, CaseStatus.Activated);
        }
    }

    // 發起投票
    function _startCaseVoting(uint256 _caseNum) internal {
        require(cases[_caseNum].status == CaseStatus.Activated, "Case is not started");

        //check voting duration is greater than 0
        require(cases[_caseNum].votingDuration > 0, "Voting duration must be greater than 0");

        _updateCaseStatus(_caseNum, CaseStatus.Voting);
        cases[_caseNum].votingStartTime = block.timestamp;
    }

    // 執行案件
    function _executeCase(uint256 _caseNum) internal {
        require(cases[_caseNum].status == CaseStatus.Voting, "Case is not voting");
        CaseResult memory caseResult = _getCaseResult(_caseNum);
        require(caseResult.voteEnded, "Case is not ended");

        // 記錄最後勝者(可能為平手)，如果是平手則為address(0)
        cases[_caseNum].winner = caseResult.currentWinner;
        cases[_caseNum].status = CaseStatus.Executed;
    }

    // 回滾案件
    function _rollbackCase(uint256 _caseNum) internal virtual {
        cases[_caseNum].status = CaseStatus.Activated;
        cases[_caseNum].votingStartTime = 0;
        cases[_caseNum].winner = address(0);
    }

    function _cancelCase(uint256 _caseNum) internal virtual returns (bool sweepCompensation) {
        require(
            cases[_caseNum].status == CaseStatus.Activated || cases[_caseNum].status == CaseStatus.Inactivated,
            "Case is not activated or inactivated"
        );

        require(cancelCaseRequests[_caseNum].approved[msg.sender] == false, "Sender has already approved");

        cancelCaseRequests[_caseNum].approved[msg.sender] = true;
        cancelCaseRequests[_caseNum].approveCount++;

        sweepCompensation = false;

        if (cancelCaseRequests[_caseNum].approveCount >= 2) {
            cases[_caseNum].status = CaseStatus.Abandoned;
            sweepCompensation = true;
        }
    }

    function getCaseName(uint256 caseNum) public view returns (string memory) {
        return cases[caseNum].caseName;
    }

    function getCaseStatus(uint256 caseNum) public view returns (CaseStatus) {
        return cases[caseNum].status;
    }

    function getCaseDescription(uint256 caseNum) public view returns (string memory) {
        return cases[caseNum].caseDescription;
    }

    function getCaseCompensationA(uint256 caseNum) public view returns (uint256) {
        return cases[caseNum].compensationA;
    }

    function getCaseCompensationB(uint256 caseNum) public view returns (uint256) {
        return cases[caseNum].compensationB;
    }

    function getCaseWinner(uint256 caseNum) public view returns (address) {
        return cases[caseNum].winner;
    }

    function getCaseVotingDuration(uint256 caseNum) public view returns (uint256) {
        return cases[caseNum].votingDuration;
    }

    function getCaseVotersCount(uint256 caseNum) public view returns (uint256) {
        return cases[caseNum].voters.length;
    }

    function getCaseNumberOfVotes(uint256 caseNum, address voter) public view returns (uint256) {
        return cases[caseNum].numberOfVotes[voter];
    }

    function getCaseIsPaidA(uint256 caseNum) public view returns (bool) {
        return cases[caseNum].isPaidA;
    }

    function getCaseIsPaidB(uint256 caseNum) public view returns (bool) {
        return cases[caseNum].isPaidB;
    }

    function getCaseNumber() public view returns (uint256) {
        return currentCaseNum + 1;
    }

    function getCaseVoterChoice(uint256 caseNum, address voter) public view returns (address) {
        return cases[caseNum].voterChoice[voter];
    }

    function getCaseVoterHasClaimed(uint256 caseNum, address voter) public view returns (bool) {
        return cases[caseNum].voterHasClaimed[voter];
    }

    function getCaseAllocationMode(uint256 caseNum) public view returns (uint256) {
        return cases[caseNum].allocationMode;
    }

}
