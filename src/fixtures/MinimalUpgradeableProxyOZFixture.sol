// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import { MINIMAL_PROXY_OZ_ADDRESS, MINIMAL_PROXY_OZ_SALT } from "src/Constants.sol";
import { MinimalUpgradeableProxyOZ } from "src/MinimalUpgradeableProxyOZ.sol";

/**
 * @title MinimalUpgradeableProxyOZFixture
 * @notice A helper library for deploying the MinimalUpgradeableProxyOZ in tests. Import and call in
 * the setUp() function.
 */
library MinimalUpgradeableProxyOZFixture {

    address constant CREATE2_FACTORY = 0x4e59b44847b379578588920cA78FbF26c0B4956C;
    MinimalUpgradeableProxyOZ internal constant MINIMAL_UPGRADEABLE_PROXY_OZ_IMPLEMENTATION =
        MinimalUpgradeableProxyOZ(MINIMAL_PROXY_OZ_ADDRESS);

    function setUpMinimalUpgradeableProxyOZFixture() public returns (address) {
        if (address(MINIMAL_UPGRADEABLE_PROXY_OZ_IMPLEMENTATION).code.length > 0) {
            return MINIMAL_PROXY_OZ_ADDRESS;
        }

        (bool success, bytes memory result) = CREATE2_FACTORY.call(
            abi.encodePacked(MINIMAL_PROXY_OZ_SALT, type(MinimalUpgradeableProxyOZ).creationCode)
        );
        bytes20 resultBytes;
        /// @solidity memory-safe-assembly
        assembly {
            resultBytes := mload(add(result, 0x20))
        }
        address resultAddress = address(resultBytes);
        require(success, "Failed to deploy MinimalUpgradeableProxyOZ");
        require(
            resultAddress == MINIMAL_PROXY_OZ_ADDRESS, "MinimalUpgradeableProxyOZ address mismatch"
        );
        return resultAddress;
    }

    function getAddress() public pure returns (address) {
        return address(MINIMAL_UPGRADEABLE_PROXY_OZ_IMPLEMENTATION);
    }

    function getType() public pure returns (MinimalUpgradeableProxyOZ) {
        return MINIMAL_UPGRADEABLE_PROXY_OZ_IMPLEMENTATION;
    }

}
