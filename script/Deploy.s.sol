// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { BaseCreate2Script } from "create2-helpers-script/BaseCreate2Script.s.sol";
import { Script, console2 } from "forge-std/Script.sol";
import { MinimalUpgradeableProxySolady } from "src/MinimalUpgradeableProxySolady.sol";
import { ProxyFactory } from "src/ProxyFactory.sol";

contract Deploy is BaseCreate2Script {

    function run() public {
        string[] memory networks = vm.envString("NETWORKS", ",");
        string[] memory rpcUrls = new string[](networks.length);
        for (uint256 i = 0; i < networks.length; i++) {
            rpcUrls[i] = getChain(networks[i]).rpcUrl;
        }
        runOnNetworks(this._run, rpcUrls);
    }

    function _run() public {
        bytes32 salt = 0x0000000000000000000000000000000000000000d909d4576cd40400c2430b00;
        address expectedResult = 0x0000000000Db69BB2e1FdE2720A300e5608Bbc05;
        address addr = _create2IfNotDeployed(deployer, salt, type(ProxyFactory).creationCode);
        require(addr == expectedResult, "Deployed to wrong address");

        bytes32 minimalSalt = 0x0000000000000000000000000000000000000000985fa7bf56c20e000a501100;
        address minimalExpectedResult = 0x0000000000123FE8f366520c6619900f460C84Fa;
        address minimalAddr = _create2IfNotDeployed(
            deployer, minimalSalt, type(MinimalUpgradeableProxySolady).creationCode
        );
        require(minimalAddr == minimalExpectedResult, "Deployed to wrong address");
    }

}
