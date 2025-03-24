// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { OwnableUpgradeable } from
    "@openzeppelin-contracts-upgradeable/access/OwnableUpgradeable.sol";
import { Initializable } from "@openzeppelin-contracts-upgradeable/proxy/utils/Initializable.sol";
import { UUPSUpgradeable } from
    "@openzeppelin-contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

/**
 * @title  MinimalUpgradeableProxyOZ
 * @author emo.eth
 * @notice A minimal upgradeable proxy implementation using OpenZeppelin upgradeable contracts.
 *         Use this if your final implementation uses OpenZeppelin's OwnableUpgradeable
 *         implementation.
 */
contract MinimalUpgradeableProxyOZ is Initializable, OwnableUpgradeable, UUPSUpgradeable {

    constructor() {
        _disableInitializers();
    }

    function initialize(address initialOwner) public initializer {
        __Ownable_init(initialOwner);
    }

    function _authorizeUpgrade(address newImplementation) internal override onlyOwner { }

}
