// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import "@openzeppelin/contracts/token/ERC20/extensions/ERC4626.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/**
 * @title SincWrapper Vault
 * @author Sinclair Daemon
 * @notice A fixed-rate ERC4626-compliant vault for wrapping ERC20 tokens
 * @dev This vault overrides convertToShares and convertToAssets using a fixed exchange rate
 */
contract SincWrapper is ERC4626 {
    /**
     * @notice Fixed exchange rate between assets and shares
     */
    uint256 public immutable exchangeRate;

    /**
     * @notice Constructs the SincWrapper vault
     * @dev Inherits from OpenZeppelin ERC4626 and ERC20
     * @param _asset The underlying ERC20 token the vault accepts
     * @param _exchangeRate The multiplier used to convert assets into shares
     */
    constructor(IERC20 _asset, uint256 _exchangeRate) ERC20("Sinc Vault", "SVT") ERC4626(_asset) {
        require(_exchangeRate > 0, "Invalid exchange rate");
        exchangeRate = _exchangeRate;
    }

    /**
     * @notice Converts a given amount of underlying assets to vault shares
     * @dev Uses a fixed exchangeRate: shares = assets * exchangeRate
     * @param assets The amount of underlying tokens to convert
     * @return The number of shares corresponding to the input assets
     */
    function convertToShares(uint256 assets) public view override returns (uint256) {
        return assets * exchangeRate;
    }

    /**
     * @notice Converts a given amount of vault shares back to underlying assets
     * @dev Uses a fixed exchangeRate: assets = shares / exchangeRate
     * @param shares The number of shares to convert
     * @return The amount of underlying tokens corresponding to the shares
     */
    function convertToAssets(uint256 shares) public view override returns (uint256) {
        return shares / exchangeRate;
    }
}
