// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { BaseCreate2Script } from "create2-helpers/BaseCreate2Script.sol";
import { Script, console2 } from "forge-std/Script.sol";
import { console } from "forge-std/console.sol";
import {
    MINIMAL_PROXY_OZ_ADDRESS,
    MINIMAL_PROXY_OZ_SALT,
    MINIMAL_PROXY_SOLADY_ADDRESS,
    MINIMAL_PROXY_SOLADY_SALT,
    PROXY_FACTORY_ADDRESS,
    PROXY_FACTORY_SALT
} from "src/Constants.sol";
import { DeterministicProxyFactory } from "src/DeterministicProxyFactory.sol";
import { MinimalUpgradeableProxyOZ } from "src/MinimalUpgradeableProxyOZ.sol";
import { MinimalUpgradeableProxySolady } from "src/MinimalUpgradeableProxySolady.sol";

contract Deploy is BaseCreate2Script {

    function run() public {
        console.log("ProxyFactory initcode hash:");
        console.logBytes32(
            keccak256(abi.encodePacked(type(DeterministicProxyFactory).creationCode))
        );
        console.log("MinimalUpgradeableProxySolady initcode hash:");
        console.logBytes32(
            keccak256(abi.encodePacked(type(MinimalUpgradeableProxySolady).creationCode))
        );
        console.log("MinimalUpgradeableProxyOZ initcode hash:");
        console.logBytes32(
            keccak256(abi.encodePacked(type(MinimalUpgradeableProxyOZ).creationCode))
        );

        string[] memory networks = vm.envOr("NETWORKS", ",", new string[](0));
        string[] memory rpcUrls = new string[](networks.length);
        for (uint256 i = 0; i < networks.length; i++) {
            rpcUrls[i] = getChain(networks[i]).rpcUrl;
        }
        runOnNetworks(this._run, rpcUrls);
    }

    function _run() public {
        address proxyFactoryAddr = _create2IfNotDeployed(
            deployer, PROXY_FACTORY_SALT, type(DeterministicProxyFactory).creationCode
        );
        require(
            proxyFactoryAddr == PROXY_FACTORY_ADDRESS,
            "Deployed DeterministicProxyFactory to wrong address"
        );

        address minimalProxySoladyAddr = _create2IfNotDeployed(
            deployer, MINIMAL_PROXY_SOLADY_SALT, type(MinimalUpgradeableProxySolady).creationCode
        );
        require(
            minimalProxySoladyAddr == MINIMAL_PROXY_SOLADY_ADDRESS,
            "Deployed MinimalUpgradeableProxySolady to wrong address"
        );

        address minimalProxyOZAddr = _create2IfNotDeployed(
            deployer, MINIMAL_PROXY_OZ_SALT, type(MinimalUpgradeableProxyOZ).creationCode
        );
        require(
            minimalProxyOZAddr == MINIMAL_PROXY_OZ_ADDRESS,
            "Deployed MinimalUpgradeableProxyOZ to wrong address"
        );
    }

}
