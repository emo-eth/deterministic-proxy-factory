// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { LibClone } from "solady/utils/LibClone.sol";

/**
 * @title  ProxyFactory
 * @author emo.eth
 * @notice A factory for deploying ERC1967 proxies, beacon proxies, and clones with immutable args
 *         to deterministic addresses.
 *         Salt must encode the caller's address in the top 160 bits.
 */
contract ProxyFactory {

    error InvalidDeployer();
    error ProxyDeploymentFailed();
    error ProxyCallFailed();

    /**
     * @notice Deploys a deterministic ERC1967 proxy with a given salt.
     * @param _implementation The implementation contract to proxy.
     * @param salt The salt to use for the deployment. The caller's address must be encoded into the
     * top 160 bits of the salt.
     * @param callData The data to call on the proxy.
     */
    function deploy(address _implementation, bytes32 salt, bytes calldata callData)
        public
        payable
        returns (address)
    {
        _validateSalt(salt);
        address proxy =
            LibClone.deployDeterministicERC1967(msg.value, address(_implementation), salt);
        if (callData.length > 0) {
            (bool success,) = proxy.call(callData);
            require(success, ProxyCallFailed());
        }
        return proxy;
    }

    /**
     * @notice Clones a deterministic clone of `implementation` with immutable arguments encoded in
     * `immutableArgs` and `salt`.
     * @param implementation The implementation contract to clone.
     * @param salt The salt to use for the deployment. The caller's address must be encoded into the
     * top 160 bits of the salt.
     * @param callData The data to call on the proxy.
     * @param immutableArgs The immutable arguments to encode into the clone.
     */
    function clone(
        address implementation,
        bytes32 salt,
        bytes calldata callData,
        bytes calldata immutableArgs
    ) public payable returns (address) {
        _validateSalt(salt);
        address proxy;
        proxy = LibClone.cloneDeterministic(msg.value, implementation, immutableArgs, salt);
        if (callData.length > 0) {
            (bool success,) = proxy.call(callData);
            require(success, ProxyCallFailed());
        }
        return proxy;
    }

    /**
     * @notice Deploys a deterministic ERC1967 beacon proxy with a given salt.
     * @param _beacon The beacon contract to use for the deployment.
     * @param salt The salt to use for the deployment. The caller's address must be encoded into the
     * top 160 bits of the salt.
     * @param callData The data to call on the proxy.
     */
    function deployBeaconProxy(address _beacon, bytes32 salt, bytes calldata callData)
        public
        payable
        returns (address)
    {
        _validateSalt(salt);
        address proxy = LibClone.deployDeterministicERC1967BeaconProxy(msg.value, _beacon, salt);
        if (callData.length > 0) {
            (bool success,) = proxy.call(callData);
            require(success, ProxyCallFailed());
        }
        return proxy;
    }

    /**
     * @notice Returns the initcode hash for a deterministic ERC1967 proxy with a given initial
     * implementation.
     * @param _implementation The implementation contract to proxy.
     */
    function getInitcodeHashForProxy(address _implementation) public pure returns (bytes32) {
        return LibClone.initCodeHashERC1967(_implementation);
    }

    /**
     * @notice Returns the initcode hash for a deterministic ERC1967 beacon proxy with a given
     *         immutable beacon.
     * @param _beacon The beacon contract to use for the deployment.
     */
    function getInitcodeHashForBeaconProxy(address _beacon) public pure returns (bytes32) {
        return LibClone.initCodeHashERC1967BeaconProxy(_beacon);
    }

    /**
     * @notice Returns the initcode hash for a deterministic clone of `implementation` with
     * immutable arguments encoded in `immutableArgs`.
     * @param implementation The implementation contract to clone.
     * @param immutableArgs The immutable arguments to encode into the clone.
     */
    function getInitcodeHashForClone(address implementation, bytes calldata immutableArgs)
        public
        pure
        returns (bytes32)
    {
        return LibClone.initCodeHash(implementation, immutableArgs);
    }

    /**
     * @notice Validates that the caller's address is encoded into the top 160 bits of the salt
     * @param salt The salt to validate.
     */
    function _validateSalt(bytes32 salt) internal view {
        address deployer = address(uint160(uint256(salt) >> 96));
        if (deployer != msg.sender) {
            revert InvalidDeployer();
        }
    }

}
