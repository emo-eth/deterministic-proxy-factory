// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

/**
 * @title  PermissionedSalt
 * @author emo.eth
 * @notice A library for creating and manipulating permissioned salts.
 */
library PermissionedSalt {

    uint256 constant DEPLOYER_SHIFT = 96;

    /**
     * @notice Creates an PermissionedSalt from an address and a bytes12.
     */
    function createPermissionedSalt(address _deployer, uint96 _salt)
        internal
        pure
        returns (bytes32 permissionedSalt)
    {
        return bytes32(uint256(uint160(_deployer)) << DEPLOYER_SHIFT | _salt);
    }

    function create(address _deployer, uint96 salt)
        internal
        pure
        returns (bytes32 permissionedSalt)
    {
        return createPermissionedSalt(_deployer, salt);
    }

    /**
     * @notice Unwraps the deployer address from an PermissionedSalt.
     */
    function getDeployer(bytes32 permissionedSalt) internal pure returns (address _deployer) {
        return address(uint160(uint256(permissionedSalt) >> DEPLOYER_SHIFT));
    }

    /**
     * @notice Unwraps the bytes12 salt from an PermissionedSalt as a bytes32 to avoid redundant
     * masking by Solidity
     */
    function getSalt(bytes32 permissionedSalt) internal pure returns (uint96 _salt) {
        return uint96(uint256(permissionedSalt));
    }

}
