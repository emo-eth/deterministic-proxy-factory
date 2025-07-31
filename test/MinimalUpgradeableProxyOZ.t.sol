// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { Test } from "forge-std/Test.sol";

import { MockUpgradeableOZ } from "./lib/MockUpgradeableOZ.sol";
import { MINIMAL_PROXY_OZ_ADDRESS } from "src/Constants.sol";

import { Initializable } from "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import { LibClone } from "solady/utils/LibClone.sol";
import { MinimalUpgradeableProxyOZ } from "src/MinimalUpgradeableProxyOZ.sol";
import { MinimalUpgradeableProxyOZFixture } from "src/fixtures/MinimalUpgradeableProxyOZFixture.sol";

contract MinimalUpgradeableProxyOZTest is Test {

    address implementation;
    address proxy;

    function setUp() public {
        implementation = address(new MinimalUpgradeableProxyOZ());
    }

    function test_initialOwner() public {
        proxy = LibClone.deployERC1967(address(implementation));
        MinimalUpgradeableProxyOZ(proxy).initialize(address(this));
        assertEq(MinimalUpgradeableProxyOZ(proxy).owner(), address(this));
    }

    function test_upgrade() public {
        proxy = LibClone.deployERC1967(address(implementation));
        MinimalUpgradeableProxyOZ(proxy).initialize(address(this));

        address upgradeImplementation = address(new MockUpgradeableOZ());
        uint64 version = 2;
        uint256 initialCounter = 1;
        bytes memory callData =
            abi.encodeCall(MockUpgradeableOZ.reinitialize, (initialCounter, version));
        vm.expectEmit();
        emit Initializable.Initialized(version);
        MinimalUpgradeableProxyOZ(proxy).upgradeToAndCall(upgradeImplementation, callData);
        assertEq(MockUpgradeableOZ(proxy).counter(), initialCounter);
    }

    // Fixture tests
    function test_fixtureDeploysCorrectAddress() public {
        address deployedAddress = MinimalUpgradeableProxyOZFixture.setUpMinimalUpgradeableProxyOZ();
        assertEq(deployedAddress, MINIMAL_PROXY_OZ_ADDRESS, "Deployment address mismatch");
        assertGt(deployedAddress.code.length, 0, "MinimalUpgradeableProxyOZ not deployed");
    }

    function test_fixtureIdempotency() public {
        address firstCall = MinimalUpgradeableProxyOZFixture.setUpMinimalUpgradeableProxyOZ();
        address secondCall = MinimalUpgradeableProxyOZFixture.setUpMinimalUpgradeableProxyOZ();
        assertEq(firstCall, secondCall, "Fixture should be idempotent");
    }

}
