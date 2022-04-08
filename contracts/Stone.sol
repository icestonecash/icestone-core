// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "./interfaces/IERC20.sol";
import "./lib/TransferHelper.sol";
import "./common/ReentrancyGuard.sol";
import "./interfaces/ITokenUriConstructor.sol";
import "./interfaces/IStoneFlashBorrower.sol";
import "./interfaces/IStoneFactory.sol";
import "./lib/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";

contract Stone is ERC721Enumerable, ReentrancyGuard {
    using SafeMath for uint256;
    using Address for address;

    address public token;
    uint256 public reserve;
    address public tokenUriConstructor;
    address public factory;

    string private _tokenSymbol;
    uint256 private _tokenDecimals;
    uint256 private _lastMinted = 0;

    struct StoneData {
        uint256 unlockTime;
        uint256 value;
    }

    mapping(uint256 => StoneData) public stonesInfo;

    constructor(
        address _token, 
        string memory _name, 
        string memory _symbol, 
        address _tokenUriConstructor
    ) ERC721(_name, _symbol) {
        token = _token;
        _tokenSymbol = IERC20(_token).symbol();
        _tokenDecimals = IERC20(_token).decimals();
        tokenUriConstructor = _tokenUriConstructor;
        factory = msg.sender;
    }

    function mint(address to, uint256 unlockTime) external nonReentrant {
        require(unlockTime <= block.timestamp + ((365 days) * 10), "unlocktime-max");
        uint256 balance = _tokenBalance();
        require(balance >= reserve, "balance-lt-reserve");
        uint256 amountIn = balance.sub(reserve);
        require(amountIn > 0, "amountin-zero");

        uint256 tokenId = ++_lastMinted;
        StoneData storage stone = stonesInfo[tokenId];
        stone.unlockTime = unlockTime;
        stone.value = amountIn;

        _update(balance);
        _safeMint(to, tokenId);
    }

    function burn(uint256 tokenId) external nonReentrant {
        StoneData storage stone = stonesInfo[tokenId];

        require(_isApprovedOrOwner(msg.sender, tokenId), "not-owner-call");
        require(block.timestamp >= stone.unlockTime, "not-unlocked-stone");

        _update(reserve.sub(stone.value));
        _burn(tokenId);
    }

    function withdraw(address to) external nonReentrant returns (uint256) {
        uint256 balance = _tokenBalance();
        uint256 amountIn = balance.sub(reserve);
        require(amountIn > 0, "amountin-zero");
        TransferHelper.safeTransfer(token, to, amountIn);
        return amountIn;
    }

    function flash(
        IStoneFlashBorrower borrower, 
        uint256 amount, 
        bytes calldata data
    ) external nonReentrant returns (bool) {
        require(amount >= 100000, "amount-flash-low");
        require(amount <= reserve, "amount-exceeds-reserve");

        TransferHelper.safeTransfer(token, address(borrower), amount);
        require(
            borrower.onStoneFlash(msg.sender, token, amount, data) == IStoneFlashBorrower.onStoneFlash.selector,
            "invalid-return-data"
        );
        uint256 fee = amount.div(100000).mul(5);
        require(_tokenBalance() >= reserve + fee, "final-balance-is-small");
        _collectFee(fee);
        return true;
    }

    function _update(uint256 newReserve) private {
        require(newReserve <= _tokenBalance(), "invalid-update-balance");
        reserve = newReserve;
    }

    function _tokenBalance() private view returns (uint256) {
        return IERC20(token).balanceOf(address(this));
    }

    function tokenURI(uint256 tokenId) public override view returns (string memory) {
        StoneData storage stone = stonesInfo[tokenId];
        return ITokenUriConstructor(tokenUriConstructor).construct(
            stone.value > 0 ? stone.value / 10 ** _tokenDecimals : 0, 
            _tokenSymbol,
            stone.unlockTime
        );
    }

    function _collectFee(uint256 fee) internal {
        address feeTo = factory.isContract() ? 
                            IStoneFactory(factory).feeTo() : 
                            factory;
        TransferHelper.safeTransfer(token, feeTo, fee);
    }
}
