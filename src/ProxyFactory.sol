// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { LibClone } from "solady/utils/LibClone.sol";

/**
 * @title  ProxyFactory
 * @author emo.eth
 * @notice A factory for deploying ERC1967 proxies, beacon proxies, and clones with
 *         deterministic addresses. Each deployment method supports both standard proxies
 *         and proxies with immutable args. For security, deployment is permissioned via
 *         the deployer's address being encoded in the top 160 bits of the salt, while
 *         still maintaining deterministic addresses across chains. Uses Solady's LibClone
 *         for optimized proxy implementations.
 */
contract ProxyFactory {

    /// @notice Reverts if the caller is not encoded into the top 160 bits of the salt.
    error InvalidDeployer();
    /// @notice Reverts if the proxy deployment fails.
    error ProxyDeploymentFailed();
    /// @notice Reverts if the call to the proxy after deployment fails.
    error ProxyCallFailed();

    /**
     * @notice Deploys a deterministic ERC1967 proxy, optionally with immutable args.
     * @param implementation The implementation contract to proxy.
     * @param salt The salt to use for the deployment. The caller's address must be encoded into the
     * top 160 bits of the salt.
     * @param callData The data to call on the proxy after deployment.
     * @param immutableArgs Optional immutable arguments to encode into the proxy's bytecode. If
     * provided, they are appended to the proxy's bytecode, but *not* appended as calldata to every
     * call to the proxy implementation. These args can be read using Solady's LibClone library.
     * @return The address of the deployed proxy.
     * @dev Immutable args are best used for values that never change and are frequently accessed,
     * since reading from bytecode is cheaper than storage.
     */
    function deploy(
        address implementation,
        bytes32 salt,
        bytes calldata callData,
        bytes calldata immutableArgs
    ) public payable returns (address) {
        _validateSalt(salt);
        address proxy;
        if (immutableArgs.length > 0) {
            proxy = LibClone.deployDeterministicERC1967({
                value: msg.value,
                implementation: implementation,
                args: immutableArgs,
                salt: salt
            });
        } else {
            proxy = LibClone.deployDeterministicERC1967({
                value: msg.value,
                implementation: implementation,
                salt: salt
            });
        }
        if (callData.length > 0) {
            (bool success,) = proxy.call(callData);
            require(success, ProxyCallFailed());
        }
        return proxy;
    }

    /**
     * @notice Deploys a deterministic clone (ERC-1167 minimal proxy), optionally with immutable
     * args.
     * @param implementation The implementation contract to clone.
     * @param salt The salt to use for the deployment. The caller's address must be encoded into the
     * top 160 bits of the salt.
     * @param callData The data to call on the clone after deployment.
     * @param immutableArgs Optional immutable arguments to encode into the clone's bytecode. If
     * provided, they are appended to the clone's bytecode, but *not* appended as calldata to every
     * call to the clone implementation. These args can be read using Solady's LibClone library.
     * @return The address of the deployed clone.
     * @dev Immutable args are best used for values that never change and are frequently accessed,
     * since reading from bytecode is cheaper than storage.
     */
    function clone(
        address implementation,
        bytes32 salt,
        bytes calldata callData,
        bytes calldata immutableArgs
    ) public payable returns (address) {
        _validateSalt(salt);
        address proxy;
        if (immutableArgs.length > 0) {
            proxy = LibClone.cloneDeterministic({
                value: msg.value,
                implementation: implementation,
                args: immutableArgs,
                salt: salt
            });
        } else {
            proxy = LibClone.cloneDeterministic({
                value: msg.value,
                implementation: implementation,
                salt: salt
            });
        }
        if (callData.length > 0) {
            (bool success,) = proxy.call(callData);
            require(success, ProxyCallFailed());
        }
        return proxy;
    }

    /**
     * @notice Deploys a deterministic ERC1967 beacon proxy, optionally with immutable args.
     * @param beacon The beacon contract to use for the deployment.
     * @param salt The salt to use for the deployment. The caller's address must be encoded into the
     * top 160 bits of the salt.
     * @param callData The data to call on the proxy after deployment.
     * @param immutableArgs Optional immutable arguments to encode into the proxy's bytecode. If
     * provided, they are appended to the proxy's bytecode, but *not* appended as calldata to every
     * call to the proxy implementation. These args can be read using Solady's LibClone library.
     * @return The address of the deployed proxy.
     * @dev Immutable args are best used for values that never change and are frequently accessed,
     * since reading from bytecode is cheaper than storage.
     */
    function deployBeaconProxy(
        address beacon,
        bytes32 salt,
        bytes calldata callData,
        bytes calldata immutableArgs
    ) public payable returns (address) {
        _validateSalt(salt);
        address proxy;
        if (immutableArgs.length > 0) {
            proxy = LibClone.deployDeterministicERC1967BeaconProxy({
                value: msg.value,
                beacon: beacon,
                args: immutableArgs,
                salt: salt
            });
        } else {
            proxy = LibClone.deployDeterministicERC1967BeaconProxy(msg.value, beacon, salt);
        }
        if (callData.length > 0) {
            (bool success,) = proxy.call(callData);
            require(success, ProxyCallFailed());
        }
        return proxy;
    }

    /**
     * @notice Returns the initcode hash for a deterministic ERC1967 proxy, optionally with
     * immutable args.
     * @param _implementation The implementation contract to proxy.
     * @param immutableArgs Optional immutable arguments to encode into the proxy's bytecode.
     * @return The initcode hash of the proxy.
     */
    function getInitcodeHashForProxy(address _implementation, bytes calldata immutableArgs)
        public
        pure
        returns (bytes32)
    {
        if (immutableArgs.length > 0) {
            return LibClone.initCodeHashERC1967(_implementation, immutableArgs);
        }
        return LibClone.initCodeHashERC1967(_implementation);
    }

    /**
     * @notice Returns the initcode hash for a deterministic ERC1967 beacon proxy, optionally with
     * immutable args.
     * @param _beacon The beacon contract to use for the deployment.
     * @param immutableArgs Optional immutable arguments to encode into the proxy's bytecode.
     * @return The initcode hash of the proxy.
     */
    function getInitcodeHashForBeaconProxy(address _beacon, bytes calldata immutableArgs)
        public
        pure
        returns (bytes32)
    {
        if (immutableArgs.length > 0) {
            return LibClone.initCodeHashERC1967BeaconProxy(_beacon, immutableArgs);
        }
        return LibClone.initCodeHashERC1967BeaconProxy(_beacon);
    }

    /**
     * @notice Returns the initcode hash for a deterministic minimal proxy (ERC-1167), optionally
     * with immutable args.
     * @param implementation The implementation contract to clone.
     * @param immutableArgs Optional immutable arguments to encode into the proxy's bytecode.
     * @return The initcode hash of the minimal proxy.
     */
    function getInitcodeHashForClone(address implementation, bytes calldata immutableArgs)
        public
        pure
        returns (bytes32)
    {
        if (immutableArgs.length > 0) {
            return LibClone.initCodeHash(implementation, immutableArgs);
        }
        return LibClone.initCodeHash(implementation);
    }

    /**
     * @notice Validates that the deployer encoded in the salt matches msg.sender
     * @param salt The salt to validate. The deployer's address must be encoded in the top 160 bits.
     * @dev This ensures that only the address encoded in the salt can deploy to the deterministic
     * address derived from that salt, while still maintaining deterministic addresses across
     * chains.
     */
    function _validateSalt(bytes32 salt) internal view {
        address deployer = address(uint160(uint256(salt) >> 96));
        if (deployer != msg.sender) {
            revert InvalidDeployer();
        }
    }

}
