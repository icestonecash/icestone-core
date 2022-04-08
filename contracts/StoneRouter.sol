// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "./interfaces/IWETH.sol";
import "./interfaces/IStone.sol";
import "./interfaces/IStoneFactory.sol";
import "./lib/TransferHelper.sol";
import "./lib/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

contract StoneRouter is ReentrancyGuard {
    IWETH public weth;
    IStoneFactory public factory;

    constructor(IStoneFactory _factory, IWETH _weth) {
        weth = _weth;
        factory = _factory;
    }

    function depositEth(address to, uint256 unlockTime) external payable {
        address wethStone = factory.createOrGetStone(address(weth));
        weth.deposit{value: msg.value}();
        weth.transfer(wethStone, msg.value);
        IStone(wethStone).mint(to, unlockTime);
    }

    function withdrawEth(uint256 tokenId, address to) external nonReentrant {
        address wethStone = factory.createOrGetStone(address(weth));
        uint256 amount = _burnAndWithdraw(wethStone, tokenId, address(this));
        weth.withdraw(amount);
        TransferHelper.safeTransferETH(to, amount);
    }

    function deposit(address token, address to, uint256 value, uint256 unlockTime) external nonReentrant {
        address stone = factory.createOrGetStone(token);
        TransferHelper.safeTransferFrom(token, msg.sender, stone, value);
        IStone(stone).mint(to, unlockTime);
    }
    
    function withdraw(address token, uint256 tokenId, address to) external nonReentrant {
        address stone = factory.createOrGetStone(token);
        _burnAndWithdraw(stone, tokenId, to);
    }

    function _burnAndWithdraw(address stone, uint256 tokenId, address to) private returns (uint256) {
        IStone(stone).burn(tokenId);
        return IStone(stone).withdraw(to);
    }

    function onERC721Received(address operator, address, uint256 tokenId, bytes calldata) external returns (bytes4) {
        _burnAndWithdraw(msg.sender, tokenId, operator);
        return IERC721Receiver.onERC721Received.selector;
    }

    receive() external payable {}
}
