// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {ERC4626} from "@openzeppelin/contracts/token/ERC20/extensions/ERC4626.sol";

/**
 * @title Wrapper - ERC4626 tokenized vault wrapper with adjustable exchange rate
 * @notice Wraps an underlying ERC20 asset and issues shares based on an adjustable exchange rate
 * @dev Uses OpenZeppelin's ERC4626 standard with custom exchange rate logic
 */
contract Wrapper is ERC4626 {
    using SafeERC20 for IERC20;

    /**
     * @notice Owner address authorized to update the exchange rate
     */
    address public owner;

    /**
     * @notice Current exchange rate between assets and shares, scaled by 1e18
     * @dev Must always be between MIN_EXCHANGE_RATE and MAX_EXCHANGE_RATE
     */
    uint256 public exchangeRate;

    /**
     * @notice Underlying asset token this vault accepts and manages
     */
    IERC20 asset;

    /**
     * @notice Maximum allowed exchange rate (scaled by 1e18)
     */
    uint256 public constant MAX_EXCHANGE_RATE = 1e18;

    /**
     * @notice Minimum allowed exchange rate (scaled by 1e18)
     */
    uint256 public constant MIN_EXCHANGE_RATE = 1;

    /**
     * @notice Error thrown when an exchange rate is out of bounds
     */
    error InvalidRate();

    /**
     * @notice Error thrown when caller is not authorized (not owner)
     */
    error NotAuthorized();

    /**
     * @notice Error thrown when zero amount is sent where non-zero is required
     */
    error ZeroAmount();

    /**
     * @notice Modifier to restrict functions to only the contract owner
     */
    modifier onlyOwner() {
        if (msg.sender != owner) revert NotAuthorized();
        _;
    }

    /**
     * @notice Constructor sets initial asset, exchange rate, and owner
     * @param _asset Address of the underlying ERC20 asset token
     * @param initialRate Initial exchange rate between assets and shares (scaled by 1e18)
     * @dev Reverts if initialRate is outside allowed bounds
     */
    constructor(IERC20 _asset, uint256 initialRate) ERC20("Wrapped Sinclair", "WSIN") ERC4626(_asset) {
        if (initialRate < MIN_EXCHANGE_RATE || initialRate > MAX_EXCHANGE_RATE) {
            revert InvalidRate();
        }
        asset = _asset;
        exchangeRate = initialRate;
        owner = msg.sender;
    }

    /**
     * @notice Allows the owner to update the exchange rate
     * @param updatedRate New exchange rate to set (scaled by 1e18)
     * @dev Reverts if updatedRate is outside allowed bounds
     */
    function setExchangeRate(uint256 updatedRate) external onlyOwner {
        if (updatedRate < MIN_EXCHANGE_RATE || updatedRate > MAX_EXCHANGE_RATE) {
            revert InvalidRate();
        }
        exchangeRate = updatedRate;
    }

    /**
     * @notice Converts an amount of assets to the corresponding amount of shares
     * @param assets The amount of the underlying asset to convert
     * @return shares The equivalent amount of shares based on the current exchange rate
     * @dev Uses fixed-point math with scaling factor 1e18
     */
    function convertToShares(uint256 assets) public view override returns (uint256) {
        return (assets * exchangeRate) / 1e18;
    }

    /**
     * @notice Converts an amount of shares to the corresponding amount of assets
     * @param shares The amount of shares to convert
     * @return assets The equivalent amount of underlying assets based on the current exchange rate
     * @dev Uses fixed-point math with scaling factor 1e18
     */
    function convertToAssets(uint256 shares) public view override returns (uint256) {
        return (shares * 1e18) / exchangeRate;
    }

    /**
     * @notice Simulates the amount of shares received for depositing a given amount of assets
     * @param assets The amount of assets to deposit
     * @return shares The estimated amount of shares minted
     */
    function previewDeposit(uint256 assets) public view override returns (uint256) {
        return convertToShares(assets);
    }

    /**
     * @notice Simulates the amount of assets needed to mint a given amount of shares
     * @param shares The amount of shares to mint
     * @return assets The estimated amount of assets required
     */
    function previewMint(uint256 shares) public view override returns (uint256) {
        return convertToAssets(shares);
    }

    /**
     * @notice Simulates the amount of shares needed to withdraw a given amount of assets
     * @param assets The amount of assets to withdraw
     * @return shares The estimated amount of shares to burn
     */
    function previewWithdraw(uint256 assets) public view override returns (uint256) {
        return convertToShares(assets);
    }

    /**
     * @notice Simulates the amount of assets returned for burning a given amount of shares
     * @param shares The amount of shares to burn
     * @return assets The estimated amount of assets to receive
     */
    function previewRedeem(uint256 shares) public view override returns (uint256) {
        return convertToAssets(shares);
    }

    /**
     * @notice Deposits underlying assets into the vault and mints corresponding shares
     * @param assets The amount of underlying assets to deposit
     * @dev Reverts if `assets` is zero
     * @dev User must have approved the vault to spend at least `assets` tokens
     */
    function deposit(uint256 assets) public {
        if (assets == 0) revert ZeroAmount();

        asset.safeTransferFrom(msg.sender, address(this), assets);
        uint256 shares = convertToShares(assets);
        _mint(msg.sender, shares);
    }

    /**
     * @notice Burns shares from sender and withdraws corresponding underlying assets
     * @param shares The amount of shares to burn
     * @dev Reverts if `shares` is zero
     * @dev Transfers underlying assets back to the sender
     */
    function withdraw(uint256 shares) external {
        if (shares == 0) revert ZeroAmount();

        uint256 assets = convertToAssets(shares);
        _burn(msg.sender, shares);
        asset.safeTransfer(msg.sender, assets);
    }

    /**
     * @notice Returns total amount of underlying assets held by the vault
     * @return totalAssetsHeld The total underlying asset balance in the vault contract
     */
    function totalAssets() public view override returns (uint256) {
        return asset.balanceOf(address(this));
    }
}
