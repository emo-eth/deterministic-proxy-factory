// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import { PermissionedSalt } from "../src/PermissionedSalt.sol";
import { Test } from "forge-std/Test.sol";

contract PermissionedSaltTest is Test {

    function setUp() public { }

    function testCreatePermissionedSalt() public {
        address deployer = makeAddr("deployer");
        uint96 salt = 123;
        bytes32 permissionedSalt = PermissionedSalt.createPermissionedSalt(deployer, salt);

        // Verify deployer is correctly stored in upper 160 bits
        assertEq(
            PermissionedSalt.getDeployer(permissionedSalt), deployer, "Incorrect deployer extracted"
        );

        // Verify salt is correctly stored in lower 96 bits
        assertEq(PermissionedSalt.getSalt(permissionedSalt), salt, "Incorrect salt extracted");
    }

    function testMaxValues() public {
        address deployer = makeAddr("deployer");
        uint96 maxSalt = type(uint96).max;
        bytes32 permissionedSalt = PermissionedSalt.createPermissionedSalt(deployer, maxSalt);

        assertEq(
            PermissionedSalt.getDeployer(permissionedSalt),
            deployer,
            "Incorrect deployer with max salt"
        );
        assertEq(PermissionedSalt.getSalt(permissionedSalt), maxSalt, "Incorrect max salt value");
    }

    function testFuzz_CreateAndExtract(address deployer, uint96 salt) public pure {
        bytes32 permissionedSalt = PermissionedSalt.createPermissionedSalt(deployer, salt);

        assertEq(
            PermissionedSalt.getDeployer(permissionedSalt), deployer, "Fuzzing: Incorrect deployer"
        );
        assertEq(PermissionedSalt.getSalt(permissionedSalt), salt, "Fuzzing: Incorrect salt");
    }

}
