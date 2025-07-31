// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { MockUpgradeableSolady } from "./lib/MockUpgradeableSolady.sol";
import { Test } from "forge-std/Test.sol";
import { Initializable } from "solady/utils/Initializable.sol";
import { LibClone } from "solady/utils/LibClone.sol";
import { MINIMAL_PROXY_SOLADY_ADDRESS } from "src/Constants.sol";
import { MinimalUpgradeableProxySolady } from "src/MinimalUpgradeableProxySolady.sol";
import { MinimalUpgradeableProxySoladyFixture } from
    "src/fixtures/MinimalUpgradeableProxySoladyFixture.sol";

contract MinimalUpgradeableProxySoladyTest is Test {

    address implementation;
    address proxy;

    function setUp() public {
        implementation = address(new MinimalUpgradeableProxySolady());
    }

    function test_initialOwner() public {
        proxy = LibClone.deployERC1967(address(implementation));
        MinimalUpgradeableProxySolady(proxy).initialize(address(this));
        assertEq(MinimalUpgradeableProxySolady(proxy).owner(), address(this));
    }

    function test_upgrade() public {
        proxy = LibClone.deployERC1967(address(implementation));
        MinimalUpgradeableProxySolady(proxy).initialize(address(this));

        address upgradeImplementation = address(new MockUpgradeableSolady());
        uint64 version = 2;
        uint256 initialCounter = 1;
        bytes memory callData =
            abi.encodeCall(MockUpgradeableSolady.reinitialize, (initialCounter, version));
        vm.expectEmit();
        emit Initializable.Initialized(version);
        MinimalUpgradeableProxySolady(proxy).upgradeToAndCall(upgradeImplementation, callData);
        assertEq(MockUpgradeableSolady(proxy).counter(), initialCounter);
    }

    // Fixture tests
    function test_fixtureDeploysCorrectAddress() public {
        address deployedAddress =
            MinimalUpgradeableProxySoladyFixture.setUpMinimalUpgradeableProxySolady();
        assertEq(deployedAddress, MINIMAL_PROXY_SOLADY_ADDRESS, "Deployment address mismatch");
        assertGt(deployedAddress.code.length, 0, "MinimalUpgradeableProxySolady not deployed");
    }

    function test_fixtureIdempotency() public {
        address firstCall =
            MinimalUpgradeableProxySoladyFixture.setUpMinimalUpgradeableProxySolady();
        address secondCall =
            MinimalUpgradeableProxySoladyFixture.setUpMinimalUpgradeableProxySolady();
        assertEq(firstCall, secondCall, "Fixture should be idempotent");
    }

}
