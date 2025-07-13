// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "./interfaces/IVoter.sol";
import "./Governance.sol";

contract Voter is Governance, IVoter {
    mapping(address => bool) public isVoter;
    mapping(address => uint256) private voterIndex;

    address[] private voters;

    constructor(address _owner) Governance(_owner) {}

    function addVoter(address _voter) public onlyGovernance {
        require(!isVoter[_voter], "Voter already exists");

        isVoter[_voter] = true;
        voterIndex[_voter] = voters.length;
        voters.push(_voter);
    }

    function removeVoter(address _voter) public onlyGovernance {
        require(isVoter[_voter], "Voter does not exist");

        // Get the index of the voter to be removed
        uint256 indexToRemove = voterIndex[_voter];
        uint256 lastIndex = voters.length - 1;

        // If the voter is not the last one, swap with the last voter
        if (indexToRemove != lastIndex) {
            address lastVoter = voters[lastIndex];
            voters[indexToRemove] = lastVoter;
            voterIndex[lastVoter] = indexToRemove;
        }

        // Remove the last element
        voters.pop();
        delete voterIndex[_voter];
        isVoter[_voter] = false;
    }

    function getVoters() public view returns (address[] memory) {
        return voters;
    }
}
