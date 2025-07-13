// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

interface IVoter {
    function addVoter(address _voter) external;
    function removeVoter(address _voter) external;
    function getVoters() external view returns (address[] memory);
    function isVoter(address _voter) external view returns (bool);
}