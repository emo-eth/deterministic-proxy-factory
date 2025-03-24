// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { BaseCreate2Script } from "create2-helpers/BaseCreate2Script.sol";
import { Script, console2 } from "forge-std/Script.sol";
import { MinimalUpgradeableProxyOZ } from "src/MinimalUpgradeableProxyOZ.sol";
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
        require(addr == expectedResult, "Deployed ProxyFactory to wrong address");

        bytes32 minimalSalt = 0x00000000000000000000000000000000000000006be6053f98130d009aa10100;
        address minimalExpectedResult = 0x0000000000354D21D30F6CfECDF569b9fd796ADa;
        address minimalAddr = _create2IfNotDeployed(
            deployer, minimalSalt, type(MinimalUpgradeableProxySolady).creationCode
        );
        require(
            minimalAddr == minimalExpectedResult,
            "Deployed MinimalUpgradeableProxySolady to wrong address"
        );

        bytes32 minimalSaltOz = 0x000000000000000000000000000000000000000014142afe4ab30900084f1200;
        address minimalExpectedResultOz = 0x0000000000c110c7599c63EAE0C95e17b41CBb9B;
        address minimalAddrOz = _create2IfNotDeployed(
            deployer, minimalSaltOz, type(MinimalUpgradeableProxyOZ).creationCode
        );
        require(
            minimalAddrOz == minimalExpectedResultOz,
            "Deployed MinimalUpgradeableProxyOZ to wrong address"
        );
    }

}
