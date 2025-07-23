// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import { Test } from "forge-std/Test.sol";

import { PROXY_FACTORY_ADDRESS } from "src/Constants.sol";
import { MINIMAL_PROXY_SOLADY_ADDRESS } from "src/Constants.sol";
import { MINIMAL_PROXY_OZ_ADDRESS } from "src/Constants.sol";
import { MINIMAL_UUPS_UPGRADEABLE_ADDRESS } from "src/Constants.sol";
import { DeterministicProxyFactory } from "src/DeterministicProxyFactory.sol";

import { MinimalUpgradeableProxyOZ } from "src/MinimalUpgradeableProxyOZ.sol";
import { MinimalUpgradeableProxySolady } from "src/MinimalUpgradeableProxySolady.sol";

import { UUPSUpgradeable } from "@openzeppelin/contracts/proxy/utils/UUPSUpgradeable.sol";
import { PermissionedSalt } from "src/PermissionedSalt.sol";
import { DeterministicProxyFactoryFixture } from "src/fixtures/DeterministicProxyFactoryFixture.sol";

import { MinimalUUPSUpgradeableFixture } from "src/fixtures/MinimalUUPSUpgradeableFixture.sol";
import { MinimalUpgradeableProxyOZFixture } from "src/fixtures/MinimalUpgradeableProxyOZFixture.sol";
import { MinimalUpgradeableProxySoladyFixture } from
    "src/fixtures/MinimalUpgradeableProxySoladyFixture.sol";

contract UpgradeTest is UUPSUpgradeable {

    bool public initialized;

    function isUpgraded() public pure returns (bool) {
        return true;
    }

    function initialize() public {
        initialized = true;
    }

    function _authorizeUpgrade(address newImplementation) internal override { }

}

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
            MinimalUpgradeableProxySoladyFixture.setUpMinimalUpgradeableProxySolady();

        // Verify deployment address matches expected and has code
        assertEq(deployedAddress, MINIMAL_PROXY_SOLADY_ADDRESS, "Deployment address mismatch");
        assertGt(deployedAddress.code.length, 0, "MinimalUpgradeableProxySolady not deployed");
    }

    function testMinimalUpgradeableProxyOZFixture() public {
        // Test deployment
        address deployedAddress = MinimalUpgradeableProxyOZFixture.setUpMinimalUpgradeableProxyOZ();

        // Verify deployment address matches expected and has code
        assertEq(deployedAddress, MINIMAL_PROXY_OZ_ADDRESS, "Deployment address mismatch");
        assertGt(deployedAddress.code.length, 0, "MinimalUpgradeableProxyOZ not deployed");
    }

    function testMinimalUUPSUpgradeableFixture() public {
        // Test deployment
        address deployedAddress = MinimalUUPSUpgradeableFixture.setUpMinimalUUPSUpgradeable();

        // Verify deployment address matches expected and has code
        assertEq(deployedAddress, MINIMAL_UUPS_UPGRADEABLE_ADDRESS, "Deployment address mismatch");
        assertGt(deployedAddress.code.length, 0, "MinimalUUPSUpgradeable not deployed");
    }

    function testDeterministicProxyMethods() public {
        address impl = address(new UpgradeTest());
        address proxy = DeterministicProxyFactoryFixture.deterministicProxySolady({
            initialProxySalt: PermissionedSalt.createPermissionedSalt(address(this), uint96(0)),
            initialOwner: address(this),
            implementation: impl,
            callData: ""
        });
        assertEq(UpgradeTest(proxy).isUpgraded(), true);

        // do same for oz
        proxy = DeterministicProxyFactoryFixture.deterministicProxyOZ({
            initialProxySalt: PermissionedSalt.createPermissionedSalt(address(this), uint96(0)),
            initialOwner: address(this),
            implementation: impl,
            callData: ""
        });
        assertEq(UpgradeTest(proxy).isUpgraded(), true);

        // do same for uups
        proxy = DeterministicProxyFactoryFixture.deterministicProxyUUPS({
            initialProxySalt: PermissionedSalt.createPermissionedSalt(address(this), uint96(0)),
            implementation: impl,
            callData: abi.encodeCall(UpgradeTest.initialize, ())
        });
        assertEq(UpgradeTest(proxy).isUpgraded(), true);
    }

}
