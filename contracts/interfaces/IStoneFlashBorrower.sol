// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

interface IStoneFlashBorrower {
    function onStoneFlash(address operator, address token, uint256 amount, bytes memory data) external returns (bytes4);
}