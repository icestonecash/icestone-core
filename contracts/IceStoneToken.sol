// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "./common/ERC20.sol";
import "./common/StoneData.sol";
import "./lib/SafeMath.sol";
import "./interfaces/IStoneFactory.sol";
import "./interfaces/IStone.sol";

contract IceStoneToken is ERC20 {
    using SafeMath for uint256;
    address public operator;
    IStoneFactory public factory;
    mapping(address => uint256) public tokenRewardPerSecond;
    mapping(address => mapping(uint256 => uint256)) public lastClaim;

    constructor(IStoneFactory stoneFactory, uint256 premintAmount) ERC20("IceStone", "ISC", 18, premintAmount) {
        operator = msg.sender;
        factory = stoneFactory;
    }

    modifier onlyOperator {
        require(msg.sender == operator, "only-operator");
        _;
    }

    function setTokenRewardPerSecond(address token, uint256 reward) external onlyOperator {
        tokenRewardPerSecond[token] = reward;
    }

    function setOperator(address newOperator) external onlyOperator {
        operator = newOperator;
    }

    function claimableAmount(IStone stone, uint256 tokenId) public view returns (uint256 amountToClaim) {
        address token = stone.token();
        require(token != address(0), "invalid-token-address");
        require(factory.allStones(token) == address(stone), "factory-permission-denied");

        StoneData memory stoneData = stone.stonesInfo(tokenId);
        uint256 from = lastClaim[address(stone)][tokenId];
        if(from == 0) {
            from = stoneData.createdTime;
        }

        uint256 to = block.timestamp < stoneData.unlockTime ? 
                        block.timestamp :
                        stoneData.unlockTime;

        uint256 blockTimeToClaim = to - from;
        amountToClaim = blockTimeToClaim.mul(tokenRewardPerSecond[token]).mul(stoneData.value).div(1e18);
    }

    function claim(IStone stone, uint256 tokenId) public {
        uint256 amountToClaim = claimableAmount(stone, tokenId);
        address owner = stone.ownerOf(tokenId);
        require(owner == msg.sender || 
                stone.isApprovedForAll(owner, msg.sender) || 
                stone.getApproved(tokenId) == msg.sender,
                "caller-permission-denied");
        if(amountToClaim == 0) return;
        
        lastClaim[address(stone)][tokenId] = block.timestamp;
        _mint(owner, amountToClaim);
    }

    function claim(IStone[] calldata stones, uint256[] calldata tokenIds) external {
        require(stones.length == tokenIds.length, "diff-len-of-arrays");
        for (uint256 i = 0; i < stones.length; i++) {
            claim(stones[i], tokenIds[i]);
        }
    }

    function burn(uint256 amount) external {
        _burn(msg.sender, amount);
    }

    function burnFrom(address from, uint256 amount) external {
        if (allowance[from][msg.sender] != type(uint256).max) {
            allowance[from][msg.sender] = allowance[from][msg.sender].sub(amount);
        }
        _burn(from, amount);
    }
}