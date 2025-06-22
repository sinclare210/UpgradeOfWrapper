// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import {Script, console} from "forge-std/Script.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import {SincWrapper} from "../src/SincWrapper.sol";
//https://sepolia.etherscan.io/address/0x86c6d274517c13d8c6649764b3b8de5d7a08114b

contract SincWrapperScript is Script {
    SincWrapper public sincWrapper;

    function run() public {
        vm.startBroadcast();
        sincWrapper = new SincWrapper(IERC20(0x75fBb602367D3e5d798b5e2152C6efa7A48a015b), 500000);
        vm.stopBroadcast();
    }
}
