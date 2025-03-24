// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { Ownable } from "solady/auth/Ownable.sol";
import { Initializable } from "solady/utils/Initializable.sol";
import { UUPSUpgradeable } from "solady/utils/UUPSUpgradeable.sol";

contract MinimalUpgradeableProxySolady is Initializable, Ownable, UUPSUpgradeable {

    constructor() {
        _disableInitializers();
    }

    function initialize(address initialOwner) public initializer {
        _initializeOwner(initialOwner);
    }

    function _authorizeUpgrade(address newImplementation) internal override onlyOwner { }

}
