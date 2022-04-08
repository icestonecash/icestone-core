// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "../interfaces/IStoneFlashBorrower.sol";
import "../interfaces/IStone.sol";
import "../interfaces/IERC20.sol";
import "../lib/TransferHelper.sol";

contract FlashLoaner is IStoneFlashBorrower {
    address private _stoneAddressBuffer;
    uint256 private _amountToReturn;
    event FlashLoanSuccess();

    function execute(address stone, uint256 amount) external {
        _stoneAddressBuffer = stone;
        _amountToReturn = amount + ((amount / 100000) * 5);

        IStone(stone).flash(address(this), amount, "");
    }

    function executeFail(address stone, uint256 amount) external {
        _stoneAddressBuffer = stone;
        _amountToReturn = 0;
        IStone(stone).flash(address(this), amount, "");
    }

    function onStoneFlash(address, address token, uint256 amount, bytes calldata) external returns (bytes4) {
        require(msg.sender == _stoneAddressBuffer, "permission-denied");
        _stoneAddressBuffer = address(0);
        
        require(IERC20(token).balanceOf(address(this)) >= amount, "invalid-balance");
        TransferHelper.safeTransfer(token, msg.sender, _amountToReturn);
        emit FlashLoanSuccess();
        return IStoneFlashBorrower.onStoneFlash.selector;
    }
}