// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import { MINIMAL_PROXY_SOLADY_ADDRESS, MINIMAL_PROXY_SOLADY_SALT } from "src/Constants.sol";

import { MinimalUpgradeableProxySolady } from "src/MinimalUpgradeableProxySolady.sol";

library MinimalUpgradeableProxySoladyFixture {

    address constant CREATE2_FACTORY = 0x4e59b44847b379578588920cA78FbF26c0B4956C;
    MinimalUpgradeableProxySolady internal constant
        MINIMAL_UPGRADEABLE_PROXY_SOLADY_IMPLEMENTATION =
            MinimalUpgradeableProxySolady(MINIMAL_PROXY_SOLADY_ADDRESS);

    function setUpMinimalUpgradeableProxySoladyFixture() public returns (address) {
        if (address(MINIMAL_UPGRADEABLE_PROXY_SOLADY_IMPLEMENTATION).code.length > 0) {
            return MINIMAL_PROXY_SOLADY_ADDRESS;
        }

        (bool success, bytes memory result) = CREATE2_FACTORY.call(
            abi.encodePacked(
                MINIMAL_PROXY_SOLADY_SALT, type(MinimalUpgradeableProxySolady).creationCode
            )
        );
        bytes20 resultBytes;
        /// @solidity memory-safe-assembly
        assembly {
            resultBytes := mload(add(result, 0x20))
        }
        address resultAddress = address(resultBytes);
        require(success, "Failed to deploy minimal proxy solady");
        require(
            resultAddress == MINIMAL_PROXY_SOLADY_ADDRESS,
            "MinimalUpgradeableProxySolady address mismatch"
        );
        return resultAddress;
    }

    function getAddress() public pure returns (address) {
        return address(MINIMAL_UPGRADEABLE_PROXY_SOLADY_IMPLEMENTATION);
    }

    function getType() public pure returns (MinimalUpgradeableProxySolady) {
        return MINIMAL_UPGRADEABLE_PROXY_SOLADY_IMPLEMENTATION;
    }

}
