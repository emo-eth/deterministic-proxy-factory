// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import { Test } from "forge-std/Test.sol";

import { PROXY_FACTORY_ADDRESS } from "src/Constants.sol";
import { MINIMAL_PROXY_SOLADY_ADDRESS } from "src/Constants.sol";
import { MINIMAL_PROXY_OZ_ADDRESS } from "src/Constants.sol";
import { DeterministicProxyFactory } from "src/DeterministicProxyFactory.sol";

import { MinimalUpgradeableProxyOZ } from "src/MinimalUpgradeableProxyOZ.sol";
import { MinimalUpgradeableProxySolady } from "src/MinimalUpgradeableProxySolady.sol";
import { DeterministicProxyFactoryFixture } from "src/fixtures/DeterministicProxyFactoryFixture.sol";
import { MinimalUpgradeableProxyOZFixture } from "src/fixtures/MinimalUpgradeableProxyOZFixture.sol";
import { MinimalUpgradeableProxySoladyFixture } from
    "src/fixtures/MinimalUpgradeableProxySoladyFixture.sol";

contract FixturesTest is Test {

    function testDeterministicProxyFactoryFixture() public {
        // Test deployment
        address result = DeterministicProxyFactoryFixture.setUpDeterministicProxyFactory();

        // Verify the factory was deployed to the expected address with code
        assertEq(result, PROXY_FACTORY_ADDRESS, "Deployment address mismatch");
        assertGt(result.code.length, 0, "DeterministicProxyFactory not deployed");
    }

    function testMinimalUpgradeableProxySoladyFixture() public {
        // Test deployment
        address deployedAddress =
            MinimalUpgradeableProxySoladyFixture.setUpMinimalUpgradeableProxySoladyFixture();

        // Verify deployment address matches expected and has code
        assertEq(deployedAddress, MINIMAL_PROXY_SOLADY_ADDRESS, "Deployment address mismatch");
        assertGt(deployedAddress.code.length, 0, "MinimalUpgradeableProxySolady not deployed");
    }

    function testMinimalUpgradeableProxyOZFixture() public {
        // Test deployment
        address deployedAddress =
            MinimalUpgradeableProxyOZFixture.setUpMinimalUpgradeableProxyOZFixture();

        // Verify deployment address matches expected and has code
        assertEq(deployedAddress, MINIMAL_PROXY_OZ_ADDRESS, "Deployment address mismatch");
        assertGt(deployedAddress.code.length, 0, "MinimalUpgradeableProxyOZ not deployed");
    }

}
