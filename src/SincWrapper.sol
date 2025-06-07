// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.27;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {ERC4626} from "@openzeppelin/contracts/token/ERC20/extensions/ERC4626.sol";

contract Wrapper is ERC4626{
    using SafeERC20 for IERC20;

    IERC20 token;

     constructor(IERC20 _token)
        ERC20("Wrapped Sinclair", "WSIN")
        ERC4626(_token)
    {
        token = _token;
    }

    function deposit () public {

    }

    function withdraw () public {

    }
}
