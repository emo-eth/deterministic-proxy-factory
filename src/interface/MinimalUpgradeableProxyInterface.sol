// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4;

interface MinimalUpgradeableProxyInterface {

    event Initialized(uint64 version);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event Upgraded(address indexed implementation);

    function initialize(address initialOwner) external;
    function owner() external view returns (address);
    function proxiableUUID() external view returns (bytes32);
    function transferOwnership(address newOwner) external;
    function upgradeToAndCall(address newImplementation, bytes memory data) external payable;

}
