// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import { PROXY_FACTORY_ADDRESS, PROXY_FACTORY_SALT } from "src/Constants.sol";
import { DeterministicProxyFactory } from "src/DeterministicProxyFactory.sol";

library DeterministicProxyFactoryFixture {

    address constant CREATE2_FACTORY = 0x4e59b44847b379578588920cA78FbF26c0B4956C;
    DeterministicProxyFactory internal constant DETERMINISTIC_PROXY_FACTORY =
        DeterministicProxyFactory(PROXY_FACTORY_ADDRESS);

    function setUpDeterministicProxyFactory() public returns (address) {
        if (address(DETERMINISTIC_PROXY_FACTORY).code.length > 0) {
            return PROXY_FACTORY_ADDRESS;
        }
        (bool success, bytes memory result) = CREATE2_FACTORY.call(
            abi.encodePacked(PROXY_FACTORY_SALT, type(DeterministicProxyFactory).creationCode)
        );
        bytes20 resultBytes;
        /// @solidity memory-safe-assembly
        assembly {
            resultBytes := mload(add(result, 0x20))
        }
        address resultAddress = address(resultBytes);
        require(success, "Failed to deploy DeterministicProxyFactory");
        require(
            resultAddress == PROXY_FACTORY_ADDRESS, "DeterministicProxyFactory address mismatch"
        );
        return resultAddress;
    }

}
