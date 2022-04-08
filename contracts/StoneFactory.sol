// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "./Stone.sol";

contract StoneFactory is ReentrancyGuard {
    event NewStone(address indexed stone, address indexed token);

    mapping(address => address) public allStones;
    address[] public allStonesList;
    address public feeTo;

    string public constant NAME_PREFIX = "BETA-STONE-";
    string public constant SYMBOL_PREFIX = "BS";

    address public tokenUriConstructor;

    constructor(address _tokenUriConstructor) {
        tokenUriConstructor = _tokenUriConstructor;
        feeTo = msg.sender;
    }

    function createStone(address token) public nonReentrant returns (address stone) {
        require(allStones[token] == address(0), "already-exists-stone");
        string memory tokenSymbol = IERC20(token).symbol();
        string memory name = string(abi.encodePacked(NAME_PREFIX, tokenSymbol));
        string memory symbol = string(abi.encodePacked(SYMBOL_PREFIX, tokenSymbol));
        Stone newStone = new Stone(token, name, symbol, tokenUriConstructor);
        stone = address(newStone);

        allStones[token] = stone;
        allStonesList.push(address(stone));
        emit NewStone(stone, token);
    }

    function createOrGetStone(address token) public returns (address stone) {
        if(allStones[token] == address(0)) {
            stone = createStone(token);
        } else {
            stone = allStones[token];
        }
    }

    function allStonesListLen() public view returns (uint256) {
        return allStonesList.length;
    }

    function setFeeTo(address newFeeTo) public {
        require(msg.sender == feeTo);
        feeTo = newFeeTo;
    }
}