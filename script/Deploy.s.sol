// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { BaseCreate2Script } from "create2-helpers/BaseCreate2Script.sol";
import { Script, console2 } from "forge-std/Script.sol";
import {
    DETERMINISTIC_PROXY_FACTORY_ADDRESS,
    DETERMINISTIC_PROXY_FACTORY_SALT,
    MINIMAL_UUPS_UPGRADEABLE_ADDRESS,
    MINIMAL_UUPS_UPGRADEABLE_SALT
} from "src/Constants.sol";
import { DeterministicProxyFactory } from "src/DeterministicProxyFactory.sol";

import { MinimalUUPSUpgradeable } from "src/MinimalUUPSUpgradeable.sol";

contract Deploy is BaseCreate2Script {

    function run() public {
        console2.log("ProxyFactory initcode hash:");
        console2.logBytes32(
            keccak256(abi.encodePacked(type(DeterministicProxyFactory).creationCode))
        );
        console2.log("MinimalUUPSUpgradeable initcode hash:");
        console2.logBytes32(keccak256(abi.encodePacked(type(MinimalUUPSUpgradeable).creationCode)));

        string[] memory networks = vm.envOr("NETWORKS", ",", new string[](0));
        string[] memory rpcUrls = new string[](networks.length);
        for (uint256 i = 0; i < networks.length; i++) {
            rpcUrls[i] = vm.rpcUrl(networks[i]);
        }
        runOnNetworks(_run, rpcUrls);
    }

    function _run() internal {
        console2.log("Deploying DeterministicProxyFactory");
        address proxyFactoryAddr = _create2IfNotDeployed(
            deployer, DETERMINISTIC_PROXY_FACTORY_SALT, type(DeterministicProxyFactory).creationCode
        );
        console2.log("Deployed DeterministicProxyFactory to address:", proxyFactoryAddr);
        require(
            proxyFactoryAddr == DETERMINISTIC_PROXY_FACTORY_ADDRESS,
            "Deployed DeterministicProxyFactory to wrong address"
        );

        address minimalUUPSUpgradeableAddr = _create2IfNotDeployed(
            deployer, MINIMAL_UUPS_UPGRADEABLE_SALT, type(MinimalUUPSUpgradeable).creationCode
        );
        require(
            minimalUUPSUpgradeableAddr == MINIMAL_UUPS_UPGRADEABLE_ADDRESS,
            "Deployed MinimalUUPSUpgradeable to wrong address"
        );
        console2.log("Deployed MinimalUUPSUpgradeable to address:", minimalUUPSUpgradeableAddr);
    }

}
