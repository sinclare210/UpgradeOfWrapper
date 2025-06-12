// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC4626.sol";

contract SincWrapper is ERC4626 {
    mapping(address => uint256) public shareHolder;

    constructor(IERC20 asset_) ERC4626(asset_) ERC20("Wrapper Sinclair", "WSIN") {}

    function _deposit(uint256 assets_) public {
        require(assets_ > 0, "Not allowed");

        deposit(assets_, msg.sender);

        shareHolder[msg.sender] = assets_;
    }

    function _withdraw(uint256 shares, address _receiver) public {
        require(shares > 0, "Not allowedd");
        require(shareHolder[msg.sender] > 0, "Not an holder");

        require(shareHolder[msg.sender] >= shares, "Not enough shares");

        uint256 percent = (10 * shares) / 100;

        uint256 assets = shares + percent;

        redeem(assets, _receiver, msg.sender);

        shareHolder[msg.sender] -= shares;
    }

    function totalAssets() public view override returns (uint256) {
        return balanceOf(address(this));
    }

    function totalAssetsOfUser(address _user) public view returns (uint256) {
        return balanceOf(_user);
    }
}
