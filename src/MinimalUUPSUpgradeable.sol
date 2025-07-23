// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import { UUPSUpgradeable } from "solady/utils/UUPSUpgradeable.sol";

/**
 * @title  MinimalUpgradeableProxyUnsafe
 * @author emo.eth
 * @notice A minimal UUPSUpgradeable implementation using Solady's UUPSUpgradeable.
 *         WARNING: This contract implements no initializers or ownable interface.
 *         The upgrade is not gated to an owner. It must be deployed **and upgraded**
 *         atomically. The upgrade process should initialize the contract and override the
 *         _authorizeUpgrade function to be permissioned.
 */
contract MinimalUUPSUpgradeable is UUPSUpgradeable {

    constructor() {
        // no initializers to disable
    }

    /**
     * @notice WARNING: The upgrade is not gated to owner; it must be deployed **and upgraded**
     * atomically; the upgrade process must initialize the contract and override this function to be
     * permissioned.
     */
    function _authorizeUpgrade(address newImplementation) internal override { }

}
