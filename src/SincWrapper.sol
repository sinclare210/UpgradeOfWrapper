// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.27;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {ERC4626} from "@openzeppelin/contracts/token/ERC20/extensions/ERC4626.sol";

contract Wrapper is ERC4626 {
    using SafeERC20 for IERC20;

    IERC20 token;

    address owner;

    uint256 exchangeRate;

    uint256 public constant MAX_EXCHANGE_RATE = 1e18;
    uint256 public constant MIN_EXCHANGE_RATE = 1;

    error TooMuch();
    error InvalidRate();
    error NotAuthorized();
    error CantSendZero();

    constructor(IERC20 _token, uint256 initialRate) ERC20("Wrapped Sinclair", "WSIN") ERC4626(_token) {
        token = _token;
        if (initialRate >= MIN_EXCHANGE_RATE && initialRate <= MAX_EXCHANGE_RATE) revert InvalidRate();
        exchangeRate = initialRate;
        owner = msg.sender;
    }

    modifier onlyOwner() {
        if (msg.sender != owner) revert NotAuthorized();
        _;
    }

    function setExchangeRate(uint256 updatedRate) public onlyOwner {
        if (updatedRate >= MIN_EXCHANGE_RATE && updatedRate <= MAX_EXCHANGE_RATE) revert InvalidRate();
        exchangeRate = updatedRate;
    }

    function convertToShares(uint256 assets) public view override returns (uint256) {
        return (assets * exchangeRate) / 1e18;
    }

    function convertToAssets(uint256 assets) public view override returns (uint256) {
        return (assets * 1e18) / exchangeRate;
    }

    function totalAssets() public view override returns (uint256) {
        return IERC20(asset()).balanceOf(address(this));
    }

    function previewDeposit(uint256 _asset) public view override returns (uint256) {
        return convertToShares(_asset);
    }

    function previewMint(uint256 _asset) public view override returns (uint256) {
        return convertToAssets(_asset);
    }

    function previewWithdraw(uint256 _shares) public view override returns (uint256) {
        return convertToAssets(_shares);
    }

    function previewRedeem(uint256 _shares) public view override returns (uint256) {
        return convertToAssets(_shares);
    }

    function deposit(uint256 _asset) public {
        if (_asset <= 0) revert CantSendZero();
        token.safeTransferFrom(msg.sender, address(this), _asset);
        uint256 shares = convertToShares(_asset);
        _mint(msg.sender, shares);
    }

    function withdraw(uint256 shares) public {
        if (shares == 0) revert CantSendZero();
        uint256 assets = convertToAssets(shares);
        _burn(msg.sender, shares);
        token.safeTransfer(msg.sender, assets);
    }
}
