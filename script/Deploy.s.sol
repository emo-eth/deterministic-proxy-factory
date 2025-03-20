// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { Script, console2 } from "forge-std/Script.sol";
import { MinimalUpgradeableProxySolady } from "src/MinimalUpgradeableProxySolady.sol";
import { ProxyFactory } from "src/ProxyFactory.sol";

contract Deploy is Script {

    function run() public {
        bytes32 salt = 0x0000000000000000000000000000000000000000d909d4576cd40400c2430b00;
        address expectedResult = 0x0000000000Db69BB2e1FdE2720A300e5608Bbc05;
        vm.startBroadcast();
        address addr = address(new ProxyFactory{ salt: salt }());
        vm.stopBroadcast();
        require(addr == expectedResult, "Deployed to wrong address");

        bytes32 minimalSalt = 0x0000000000000000000000000000000000000000985fa7bf56c20e000a501100;
        address minimalExpectedResult = 0x0000000000123FE8f366520c6619900f460C84Fa;
        vm.startBroadcast();
        address minimalAddr = address(new MinimalUpgradeableProxySolady{ salt: minimalSalt }());
        vm.stopBroadcast();
        require(minimalAddr == minimalExpectedResult, "Deployed to wrong address");
    }

}
