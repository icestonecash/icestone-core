// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

interface ITokenUriConstructor {
    function construct(uint256 amount, string memory symbol, uint256 unlockTime) external pure returns (string memory);
}