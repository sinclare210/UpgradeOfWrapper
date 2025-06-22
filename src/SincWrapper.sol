// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import "@openzeppelin/contracts/token/ERC20/extensions/ERC4626.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract SincWrapper is ERC4626{


    
    uint256 exchangeRate;
    
    constructor(IERC20 _asset, uint256 _exchangeRate) ERC20("Sinc Vault", "SVT") ERC4626(_asset) {
        
        exchangeRate = _exchangeRate;
    }

    function calcDeposit(uint256 _amount) public view returns (uint256) {
        uint256 amount = _amount * exchangeRate;
        return amount;
    }

    function calcWithdraw (uint256 _amount) public view returns (uint256){
        uint256 amount = _amount / exchangeRate;
        return amount;
    }

    function deposit(uint256 assets, address receiver) public override returns (uint256) {

       return super.deposit(calcDeposit(assets), receiver);

        
    }

    function withdraw(uint256 assets, address receiver, address owner) public override returns (uint256) {
        return super.withdraw(calcWithdraw(assets), receiver, owner);
        
    }

}