// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4;

interface ProxyFactoryInterface {

    error InvalidDeployer();
    error ProxyCallFailed();
    error ProxyDeploymentFailed();

    function deploy(address _implementation, bytes32 salt, bytes memory callData)
        external
        payable
        returns (address);
    function deployBeaconProxy(address _beacon, bytes32 salt, bytes memory callData)
        external
        payable
        returns (address);
    function getInitcodeHashForBeaconProxy(address _beacon) external pure returns (bytes32);
    function getInitcodeHashForProxy(address _implementation) external pure returns (bytes32);

}
