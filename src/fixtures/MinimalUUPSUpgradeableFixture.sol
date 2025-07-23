// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import { MINIMAL_UUPS_UPGRADEABLE_ADDRESS, MINIMAL_UUPS_UPGRADEABLE_SALT } from "../Constants.sol";
import { MinimalUUPSUpgradeable } from "../MinimalUUPSUpgradeable.sol";

/**
 * @title MinimalUUPSUpgradeableFixture
 * @notice A helper library for deploying the MinimalUUPSUpgradeable in tests. Import and call in
 * the setUp() function.
 */
library MinimalUUPSUpgradeableFixture {

    bytes constant MINIMAL_PROXY_INITCODE =
        hex"60a0806040523460285730608052610237908161002d82396080518181816060015261014c0152f35b5f80fdfe60806040526004361015610011575f80fd5b5f3560e01c80634f1ef286146100bf576352d1902d1461002f575f80fd5b346100bb575f7ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffc3601126100bb57307f0000000000000000000000000000000000000000000000000000000000000000036100ae5760206040517f360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc8152f35b639f03a0265f526004601cfd5b5f80fd5b60407ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffc3601126100bb5760043573ffffffffffffffffffffffffffffffffffffffff81168091036100bb576024359067ffffffffffffffff82116100bb57366023830112156100bb5781600401359067ffffffffffffffff82116100bb5736602483850101116100bb57307f0000000000000000000000000000000000000000000000000000000000000000146100ae573d5f526352d1902d6001527f360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc602060016004601d855afa510361021c57807fbc7cd75a20ee27fd9adebab32041f755214dbc6bffa90cc0225b39da2e5c2d3b5f80a281817f360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc556101fc57005b815f926024604051950185378338925af41561021457005b3d5f823e3d90fd5b6355299b496001526004601dfdfea164736f6c634300081d000a";
    address constant CREATE2_FACTORY = 0x4e59b44847b379578588920cA78FbF26c0B4956C;
    MinimalUUPSUpgradeable internal constant MINIMAL_UUPS_UPGRADEABLE_IMPLEMENTATION =
        MinimalUUPSUpgradeable(MINIMAL_UUPS_UPGRADEABLE_ADDRESS);

    function setUpMinimalUUPSUpgradeable() internal returns (address) {
        if (address(MINIMAL_UUPS_UPGRADEABLE_IMPLEMENTATION).code.length > 0) {
            return MINIMAL_UUPS_UPGRADEABLE_ADDRESS;
        }

        (bool success, bytes memory result) = CREATE2_FACTORY.call(
            abi.encodePacked(MINIMAL_UUPS_UPGRADEABLE_SALT, MINIMAL_PROXY_INITCODE)
        );
        bytes20 resultBytes;
        /// @solidity memory-safe-assembly
        assembly {
            resultBytes := mload(add(result, 0x20))
        }
        address resultAddress = address(resultBytes);
        require(success, "Failed to deploy MinimalUUPSUpgradeable");
        require(
            resultAddress == MINIMAL_UUPS_UPGRADEABLE_ADDRESS,
            "MinimalUUPSUpgradeable address mismatch"
        );
        return resultAddress;
    }

}
