// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;


interface IStone {
    function mint(address to, uint256 unlockTime) external;
    function burn(uint256 tokenId) external;
    function withdraw(address to) external returns (uint256);
    function token() external returns (address);
    function flash(
        address borrower, 
        uint256 amount, 
        bytes calldata data
    ) external returns (bool);
}