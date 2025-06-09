// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import {Script, console} from "forge-std/Script.sol";
import {Sinclair} from "../src/Sinclair.sol";

//https://sepolia.etherscan.io/address/0x75fbb602367d3e5d798b5e2152c6efa7a48a015b

contract SinclairScript is Script {
    Sinclair public sinclair;

    function run() public {
        vm.startBroadcast();
        sinclair = new Sinclair();
        vm.stopBroadcast();
    }
}
