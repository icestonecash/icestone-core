// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "./IERC20.sol";

interface IWETH {
    function deposit() external payable;
    function transfer(address, uint256) external;
    function withdraw(uint256) external;
}