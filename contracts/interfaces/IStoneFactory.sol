// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

interface IStoneFactory {
    function createStone(address token) external returns (address stone);
    function createOrGetStone(address token) external returns (address stone);
    function feeTo() external returns (address);
}