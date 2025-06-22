// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import "@openzeppelin/contracts/token/ERC20/extensions/ERC4626.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract SincWrapper is ERC4626 {
    uint256 public immutable exchangeRate;

    constructor(IERC20 _asset, uint256 _exchangeRate)
        ERC20("Sinc Vault", "SVT")
        ERC4626(_asset)
    {
        require(_exchangeRate > 0, "Invalid exchange rate");
        exchangeRate = _exchangeRate;
    }

    function convertToShares(uint256 assets) public view override returns (uint256) {
        return assets * exchangeRate;
    }

    function convertToAssets(uint256 shares) public view override returns (uint256) {
        return shares / exchangeRate;
    }
}
