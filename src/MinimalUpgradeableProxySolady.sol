// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { Ownable } from "solady/auth/Ownable.sol";
import { Initializable } from "solady/utils/Initializable.sol";
import { UUPSUpgradeable } from "solady/utils/UUPSUpgradeable.sol";

/**
 * @title  MinimalUpgradeableProxySolady
 * @author emo.eth
 * @notice A minimal upgradeable proxy implementation using Solady. Use this if your
 *         final implementation uses Solady's Ownable implementation.
 */
contract MinimalUpgradeableProxySolady is Initializable, Ownable, UUPSUpgradeable {

    constructor() {
        _disableInitializers();
    }

    function initialize(address initialOwner) public initializer {
        _initializeOwner(initialOwner);
    }

    function _authorizeUpgrade(address newImplementation) internal override onlyOwner { }

}
