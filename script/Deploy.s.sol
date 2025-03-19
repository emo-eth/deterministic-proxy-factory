// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { Script, console2 } from "forge-std/Script.sol";
import { ProxyFactory } from "src/ProxyFactory.sol";

contract Deploy is Script {

    function run() public {
        vm.startBroadcast();
        address addr = address(
            new ProxyFactory{
                salt: 0x000000000000000000000000000000000000000072a975b9d93d0d00f85c0100
            }()
        );
        vm.stopBroadcast();
        require(addr == 0x0000000000e9E17B397CE738382770166455f784, "Deployed to wrong address");
    }

}
