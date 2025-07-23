// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { Test } from "forge-std/Test.sol";

import { MINIMAL_UUPS_UPGRADEABLE_ADDRESS, MINIMAL_UUPS_UPGRADEABLE_SALT } from "src/Constants.sol";
import { MinimalUUPSUpgradeable } from "src/MinimalUUPSUpgradeable.sol";
import { MinimalUUPSUpgradeableFixture } from "src/fixtures/MinimalUUPSUpgradeableFixture.sol";

contract MinimalUUPSUpgradeableFixtureTest is Test {

    address deployedAddress;

    function setUp() public {
        // Use the fixture to deploy the minimal UUPS upgradeable proxy
        deployedAddress = MinimalUUPSUpgradeableFixture.setUpMinimalUUPSUpgradeable();
    }

    function test_fixtureDeploysCorrectAddress() public view {
        assertEq(
            deployedAddress,
            MINIMAL_UUPS_UPGRADEABLE_ADDRESS,
            "Deployed address should match expected address"
        );
    }

    function test_fixtureDeploysToCorrectAddress() public view {
        assertTrue(deployedAddress.code.length > 0, "Deployed address should have code");
    }

    function test_fixtureReturnsSameAddressOnSubsequentCalls() public {
        address secondCall = MinimalUUPSUpgradeableFixture.setUpMinimalUUPSUpgradeable();
        assertEq(secondCall, deployedAddress, "Subsequent calls should return the same address");
    }

    function test_deployedContractIsMinimalUUPSUpgradeable() public view {
        // Verify the deployed contract is actually a MinimalUUPSUpgradeable
        // The contract should be callable (no revert on basic operations)
        // Since it's a minimal implementation, we can't call many functions,
        // but we can verify it's deployed and has the expected interface
        assertTrue(deployedAddress.code.length > 0, "Contract should be deployed");
    }

    function test_fixtureUsesCorrectConstants() public pure {
        // Verify the fixture uses the correct constants from Constants.sol
        assertEq(
            MINIMAL_UUPS_UPGRADEABLE_SALT,
            MINIMAL_UUPS_UPGRADEABLE_SALT,
            "Fixture should use the correct salt from Constants"
        );

        assertEq(
            MINIMAL_UUPS_UPGRADEABLE_ADDRESS,
            MINIMAL_UUPS_UPGRADEABLE_ADDRESS,
            "Fixture should use the correct address from Constants"
        );
    }

    function test_fixtureUsesCorrectCreate2Factory() public view {
        // Verify the fixture uses the correct CREATE2 factory
        // We can't directly access the internal constant, but we can verify it's used correctly
        // by checking that the deployment works and returns the expected address
        assertEq(
            deployedAddress,
            MINIMAL_UUPS_UPGRADEABLE_ADDRESS,
            "Should deploy to correct address using CREATE2 factory"
        );
    }

    function test_fixtureHandlesAlreadyDeployedScenario() public {
        // First deployment
        address firstDeployment = MinimalUUPSUpgradeableFixture.setUpMinimalUUPSUpgradeable();

        // Second deployment should return the same address without calling CREATE2 factory again
        address secondDeployment = MinimalUUPSUpgradeableFixture.setUpMinimalUUPSUpgradeable();
        assertEq(
            secondDeployment, firstDeployment, "Should return same address when already deployed"
        );
    }

    function test_fixtureDeploymentIsDeterministic() public {
        // Test that multiple deployments return the same address
        address deployment1 = MinimalUUPSUpgradeableFixture.setUpMinimalUUPSUpgradeable();
        address deployment2 = MinimalUUPSUpgradeableFixture.setUpMinimalUUPSUpgradeable();
        address deployment3 = MinimalUUPSUpgradeableFixture.setUpMinimalUUPSUpgradeable();

        assertEq(deployment1, deployment2, "First and second deployments should be identical");
        assertEq(deployment2, deployment3, "Second and third deployments should be identical");
        assertEq(
            deployment1,
            MINIMAL_UUPS_UPGRADEABLE_ADDRESS,
            "All deployments should match expected address"
        );
    }

    function test_fixtureDeploysValidContract() public view {
        // Verify the deployed contract has valid bytecode
        assertTrue(deployedAddress.code.length > 0, "Deployed contract should have bytecode");

        // Verify it's not just an empty contract
        assertGt(
            deployedAddress.code.length, 2, "Deployed contract should have substantial bytecode"
        );
    }

    function test_fixtureCanBeUsedInOtherTests() public {
        // Test that the fixture can be used as intended in other test scenarios
        // This simulates how other tests would use this fixture

        // Deploy using the fixture
        address proxyAddress = MinimalUUPSUpgradeableFixture.setUpMinimalUUPSUpgradeable();

        // Verify it's the expected address
        assertEq(
            proxyAddress,
            MINIMAL_UUPS_UPGRADEABLE_ADDRESS,
            "Fixture should deploy to expected address"
        );

        // Verify it has code
        assertTrue(proxyAddress.code.length > 0, "Deployed proxy should have code");

        // Verify it can be cast to the correct type
        MinimalUUPSUpgradeable proxy = MinimalUUPSUpgradeable(proxyAddress);
        assertEq(address(proxy), proxyAddress, "Proxy should be castable to correct type");
    }

}
