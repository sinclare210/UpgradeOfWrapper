// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import {Script, console} from "forge-std/Script.sol";

import {SincWrapper} from "../src/SincWrapper.sol";
//https://sepolia.etherscan.io/address/0xe3094bfa319e84182f757d9fcacf49e53ef223de#writeContract

contract SincWrapperScript is Script {
    SincWrapper public sincWrapper;

    function run() public {
        vm.startBroadcast();
        sincWrapper = new SincWrapper(0x75fBb602367D3e5d798b5e2152C6efa7A48a015b, 500000);
        vm.stopBroadcast();
    }
}
