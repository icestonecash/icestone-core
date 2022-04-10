// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

interface ITokenUriConstructor {
    function construct(
        uint256 amount, 
        uint256 decimals, 
        string memory symbol, 
        uint256 unlockTime, 
        address contractAddress, 
        uint256 reward, 
        uint8 mark
    ) external view returns (string memory);
}