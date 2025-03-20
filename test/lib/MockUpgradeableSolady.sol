// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { Ownable } from "solady/auth/Ownable.sol";
import { Initializable } from "solady/utils/Initializable.sol";
import { UUPSUpgradeable } from "solady/utils/UUPSUpgradeable.sol";

contract MockUpgradeableSolady is Initializable, UUPSUpgradeable, Ownable {

    bytes32 constant INITIAL_COUNTER_SLOT = keccak256("mock.upgradeable.counter");

    function reinitialize(uint256 initialCounter, uint64 version) public reinitializer(version) {
        _setCounter(initialCounter);
    }

    function _setCounter(uint256 value) internal {
        bytes32 slot = INITIAL_COUNTER_SLOT;
        assembly {
            sstore(slot, value)
        }
    }

    function counter() public view returns (uint256 value) {
        bytes32 slot = INITIAL_COUNTER_SLOT;
        assembly {
            value := sload(slot)
        }
    }

    function _authorizeUpgrade(address) internal override onlyOwner { }

}
