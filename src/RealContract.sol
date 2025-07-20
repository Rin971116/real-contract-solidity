// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "./interfaces/IVoter.sol";
import "./interfaces/IRealContract.sol";
import "./Governance.sol";
import "./CaseManager.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract RealContract is
    Governance, // 繼承治理功能
    CaseManager, // 繼承案件管理
    IRealContract, // 實現主合約接口
    ReentrancyGuard // 繼承重入保護
{
    using SafeERC20 for IERC20;

    IVoter public immutable voter;

    bool public isRunning;

    IERC20 public immutable compensationToken;
    IERC20 public immutable voteToken;

    uint256 public feeRateForStakeCompensation;
    uint256 public feeRateForExecuteCase;

    uint256 public voteTokenAmount;

    constructor(
        address _owner, //主合約擁有者
        address _voter, //投票合約位址
        address _compensationToken, //規定保證金幣種
        address _voteToken, //規定投票幣種
        uint256 _feeRateForStakeCompensation, //存入保證金手續費率
        uint256 _feeRateForExecuteCase, //執行案件手續費率
        uint256 _voteTokenAmount //投票所需質押代幣數量
    ) Governance(_owner) {
        voter = IVoter(_voter);
        compensationToken = IERC20(_compensationToken);
        if (_voteToken != address(0)) {
            voteToken = IERC20(_voteToken);
        }
        isRunning = true;
        feeRateForStakeCompensation = _feeRateForStakeCompensation;
        feeRateForExecuteCase = _feeRateForExecuteCase;
        voteTokenAmount = _voteTokenAmount;
    }

    modifier onlyParticipantOrGovernance() {
        // 這個 modifier 將在具體函數中進行更詳細的檢查
        _;
    }

    modifier onlyParticipant() {
        // 這個 modifier 將在具體函數中進行更詳細的檢查
        _;
    }

    modifier onlyVoter() {
        require(voter.isVoter(msg.sender), "Sender is not a voter");
        _;
    }

    modifier onlyRunning() {
        require(isRunning, "Contract is not running");
        _;
    }

    function setIsRunning(bool _isRunning) public onlyGovernance {
        isRunning = _isRunning;
        emit ContractStatusChanged(_isRunning);
    }

    function setVoteTokenAmount(uint256 _voteTokenAmount) public onlyGovernance {
        voteTokenAmount = _voteTokenAmount;
    }

    function setFeeRateForStakeCompensation(uint256 _feeRateForStakeCompensation) public onlyGovernance {
        feeRateForStakeCompensation = _feeRateForStakeCompensation;
    }

    function setFeeRateForExecuteCase(uint256 _feeRateForExecuteCase) public onlyGovernance {
        feeRateForExecuteCase = _feeRateForExecuteCase;
    }

    // 添加案件
    function addCases(CaseInit[] calldata _cases) public override onlyRunning {
        for (uint256 i = 0; i < _cases.length; i++) {
            _addCase(_cases[i]);
        }
    }

    // 添加案件
    function addCase(CaseInit calldata _case) public override onlyRunning {
        _addCase(_case);
    }

    // stake compensation
    function stakeCompensation(uint256 _caseNum, bool _payA, uint256 _amount) public onlyRunning nonReentrant {
        uint256 stakeFee = (_amount * feeRateForStakeCompensation) / 10000;
        _stakeCompensation(_caseNum, compensationToken, _payA, _amount - stakeFee);

        if (_payA) {
            // 收取手續費
            // safeTransferFrom compensationToken to this contract
            compensationToken.safeTransferFrom(msg.sender, address(this), stakeFee);
            emit CaseStaked(_caseNum, msg.sender, cases[_caseNum].compensationA);
        } else if (!_payA) {
            // 收取手續費
            // safeTransferFrom compensationToken to this contract
            compensationToken.safeTransferFrom(msg.sender, address(this), stakeFee);
            emit CaseStaked(_caseNum, msg.sender, cases[_caseNum].compensationB);
        }
    }

    // 查詢當前案件結果
    function getCaseResult(uint256 _caseNum) external view returns (CaseResult memory) {
        return _getCaseResult(_caseNum);
    }

    // 啟動案件投票
    function startCaseVoting(uint256 _caseNum) public onlyRunning {
        require(
            msg.sender == cases[_caseNum].participantA || msg.sender == cases[_caseNum].participantB,
            "Sender is not a participant"
        );
        require(cases[_caseNum].status == CaseStatus.Activated, "Case is not activated");
        _startCaseVoting(_caseNum);
        emit CaseVotingStarted(_caseNum);
    }

    // 案件投票
    function vote(uint256 _caseNum, address _voteFor) public onlyVoter onlyRunning nonReentrant {
        require(cases[_caseNum].status == CaseStatus.Voting, "Case is not voting");

        require(
            block.timestamp < cases[_caseNum].votingStartTime + cases[_caseNum].votingDuration,
            "Voting duration has ended"
        );

        require(cases[_caseNum].voterIsVoted[msg.sender] == false, "Voter has already voted");

        cases[_caseNum].voterIsVoted[msg.sender] = true;
        cases[_caseNum].voters.push(msg.sender);
        cases[_caseNum].voterVotes[_voteFor]++;

        voteToken.safeTransferFrom(msg.sender, address(this), voteTokenAmount);
        cases[_caseNum].votePool += voteTokenAmount;

        emit CaseVoted(_caseNum, msg.sender, _voteFor);
    }

    // 執行案件
    function executeCase(uint256 _caseNum) public onlyRunning {
        require(
            msg.sender == cases[_caseNum].participantA || msg.sender == cases[_caseNum].participantB
                || msg.sender == governance,
            "Sender is not a participant or governance"
        );

        _executeCase(_caseNum);

        // 收取手續費
        uint256 totalExistingCompensation = cases[_caseNum].existingCompensationA + cases[_caseNum].existingCompensationB;
        uint256 executeFee = (totalExistingCompensation * feeRateForExecuteCase) / 10000;
        uint256 remainingCompensation = totalExistingCompensation - executeFee;
        uint256 totalVotes = cases[_caseNum].voterVotes[cases[_caseNum].participantA]
            + cases[_caseNum].voterVotes[cases[_caseNum].participantB];

        // 如果沒有任何人投票，則直接將保證金全數歸還，不抽取手續費
        if (totalVotes == 0) {
            compensationToken.transfer(cases[_caseNum].participantA, cases[_caseNum].existingCompensationA);
            compensationToken.transfer(cases[_caseNum].participantB, cases[_caseNum].existingCompensationB);
        }else if(totalVotes > 0){
            
            // 根據分配模式進行分配
            if (cases[_caseNum].allocationMode == 0) {
                // 模式0: 勝者全拿
                if (cases[_caseNum].winner == cases[_caseNum].participantA) {
                    compensationToken.transfer(cases[_caseNum].participantA, remainingCompensation);
                } else if (cases[_caseNum].winner == cases[_caseNum].participantB) {
                    compensationToken.transfer(cases[_caseNum].participantB, remainingCompensation);
                }
            } else {
                // 模式1: 按得票數比例分配
                uint256 participantAShare =
                    (remainingCompensation * cases[_caseNum].voterVotes[cases[_caseNum].participantA]) / totalVotes;
                uint256 participantBShare = remainingCompensation - participantAShare;

                if (participantAShare > 0) {
                    compensationToken.transfer(cases[_caseNum].participantA, participantAShare);
                }
                if (participantBShare > 0) {
                    compensationToken.transfer(cases[_caseNum].participantB, participantBShare);
                }
                
            }
        }

        emit CaseExecuted(_caseNum, cases[_caseNum].winner);
    }


    function cancelCase(uint256 _caseNum) public onlyRunning {
        require(
            msg.sender == cases[_caseNum].participantA || msg.sender == cases[_caseNum].participantB
                || msg.sender == governance,
            "Sender is not a participant or governance"
        );
        require(
            cases[_caseNum].status == CaseStatus.Activated || cases[_caseNum].status == CaseStatus.Inactivated,
            "Case is not activated or inactivated"
        );

        bool sweepCompensation = _cancelCase(_caseNum);

        if (sweepCompensation) {
            //sweep compensation
            if (cases[_caseNum].isPaidA && cases[_caseNum].compensationA > 0) {
                compensationToken.safeTransfer(cases[_caseNum].participantA, cases[_caseNum].compensationA);
            }
            if (cases[_caseNum].isPaidB && cases[_caseNum].compensationB > 0) {
                compensationToken.safeTransfer(cases[_caseNum].participantB, cases[_caseNum].compensationB);
            }
        }
        emit CaseCancelled(_caseNum);
    }
}
