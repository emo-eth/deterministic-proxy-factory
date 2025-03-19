// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import { Counter } from "../src/Counter.sol";
import { Script, console } from "forge-std/Script.sol";

contract CounterScript is Script {

    Counter public counter;

    function setUp() public { }

    function run() public {
        vm.startBroadcast();

        counter = new Counter();

        vm.stopBroadcast();
    }

}
