// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

abstract contract Governance {
    address public governance;

    modifier onlyGovernance() {
        require(msg.sender == governance, "Only the governance can call this function");
        _;
    }

    constructor(address _governance) {
        governance = _governance;
    }

    function setGovernance(address newGovernance) public onlyGovernance {
        governance = newGovernance;
    }
}
