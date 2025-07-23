// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { Test } from "forge-std/Test.sol";

import { LibClone } from "solady/utils/LibClone.sol";
import { MinimalUUPSUpgradeable } from "src/MinimalUUPSUpgradeable.sol";

// Mock implementation for testing
contract MockUpgradeableUnsafe is MinimalUUPSUpgradeable {

    uint256 public counter;

    function increment() public {
        counter++;
    }

    function someFunction() public pure returns (string memory) {
        return "hello";
    }

}

contract MinimalUUPSUpgradeableUnsafeInitialUpgradeTest is Test {

    address implementation;
    address proxy;

    function setUp() public {
        implementation = address(new MinimalUUPSUpgradeable());
    }

    function test_implementationCannotBeUpgraded() public {
        // Deploy the implementation contract directly (not as a proxy)
        MinimalUUPSUpgradeable impl = new MinimalUUPSUpgradeable();

        // Try to call upgradeToAndCall on the implementation directly
        // This should fail because the implementation is not a proxy
        address newImplementation = address(0x123);
        bytes memory data = "";

        // The call should revert because the implementation contract itself is not a proxy
        // and doesn't have the proxy storage layout
        vm.expectRevert();
        MinimalUUPSUpgradeable(address(impl)).upgradeToAndCall(newImplementation, data);
    }

    function test_implementationCannotBeUpgradedWithData() public {
        // Deploy the implementation contract directly (not as a proxy)
        MinimalUUPSUpgradeable impl = new MinimalUUPSUpgradeable();

        // Try to call upgradeToAndCall with some data
        address newImplementation = address(0x123);
        bytes memory data = abi.encodeWithSignature("someFunction()");

        // The call should revert because the implementation contract itself is not a proxy
        vm.expectRevert();
        MinimalUUPSUpgradeable(address(impl)).upgradeToAndCall(newImplementation, data);
    }

    function test_implementationCannotBeUpgradedByAnyone() public {
        // Deploy the implementation contract directly (not as a proxy)
        MinimalUUPSUpgradeable impl = new MinimalUUPSUpgradeable();

        // Try to call upgradeToAndCall from a different address
        address attacker = address(0x456);
        address newImplementation = address(0x123);
        bytes memory data = "";

        vm.prank(attacker);
        // The call should revert because the implementation contract itself is not a proxy
        vm.expectRevert();
        MinimalUUPSUpgradeable(address(impl)).upgradeToAndCall(newImplementation, data);
    }

    function test_proxiableUUIDReturnsCorrectSlot() public {
        // Deploy the implementation contract directly
        MinimalUUPSUpgradeable impl = new MinimalUUPSUpgradeable();

        // The proxiableUUID should return the ERC1967 implementation slot
        bytes32 expectedSlot = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;
        assertEq(impl.proxiableUUID(), expectedSlot);
    }

    function test_proxyCanBeUpgradedByAnyone() public {
        // Deploy a proxy using the implementation
        proxy = LibClone.deployERC1967(address(implementation));

        // Create a new implementation to upgrade to
        address newImplementation = address(new MinimalUUPSUpgradeable());
        bytes memory data = "";

        // Anyone should be able to upgrade the proxy since _authorizeUpgrade is empty
        address randomUser = address(0x789);
        vm.prank(randomUser);

        // This should succeed because the proxy can be upgraded by anyone
        MinimalUUPSUpgradeable(proxy).upgradeToAndCall(newImplementation, data);
    }

    function test_proxyCanBeUpgradedByAnyoneWithData() public {
        // Deploy a proxy using the implementation
        proxy = LibClone.deployERC1967(address(implementation));

        // Create a new mock implementation to upgrade to
        address newImplementation = address(new MockUpgradeableUnsafe());
        bytes memory data = abi.encodeWithSignature("increment()");

        // Anyone should be able to upgrade the proxy since _authorizeUpgrade is empty
        address randomUser = address(0x789);
        vm.prank(randomUser);

        // This should succeed because the proxy can be upgraded by anyone
        MinimalUUPSUpgradeable(proxy).upgradeToAndCall(newImplementation, data);

        // Verify the function was called
        assertEq(MockUpgradeableUnsafe(proxy).counter(), 1);
    }

}
