// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import "@openzeppelin/contracts/token/ERC20/extensions/ERC4626.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract SincWrapper is ERC4626{


    IERC20 asset;
    
    constructor(IERC20 _asset) ERC20("Sinc Vault", "SVT") ERC4626(_asset) {
        asset = _asset;
    }




}