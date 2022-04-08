// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "../common/StoneData.sol";

interface IStone {
    function mint(address to, uint256 unlockTime) external;
    function burn(uint256 tokenId) external;
    function withdraw(address to) external returns (uint256);
    function token() external view returns (address);
    function reserve() external view returns (uint256);
    function flash(
        address borrower, 
        uint256 amount, 
        bytes calldata data
    ) external returns (bool);
    function getApproved(uint256) external view returns (address);
    function isApprovedForAll(address,address) external view returns (bool);
    function ownerOf(uint256) external view returns (address);
    function stonesInfo(uint256) external view returns (StoneData memory);
}