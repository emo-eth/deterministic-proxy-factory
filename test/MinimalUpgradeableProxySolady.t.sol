// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { MockUpgradeableSolady } from "./lib/MockUpgradeableSolady.sol";
import { Test } from "forge-std/Test.sol";
import { Initializable } from "solady/utils/Initializable.sol";
import { LibClone } from "solady/utils/LibClone.sol";
import { MinimalUpgradeableProxySolady } from "src/MinimalUpgradeableProxySolady.sol";

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

}
