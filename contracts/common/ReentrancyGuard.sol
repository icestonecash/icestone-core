// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

contract ReentrancyGuard {
    bool private lock = false;

    modifier nonReentrant() {
        require(!lock, "non-reentrancy-guard");
        lock = true;
        _;
        lock = false;
    }
}