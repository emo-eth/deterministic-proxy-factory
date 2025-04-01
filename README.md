# Deterministic Proxy Factory

This is a simple deterministic proxy factory that allows you to deploy deterministic ERC1967 proxies, beacon proxies, and clones (ERC-1167 minimal proxies). Since initialization calls are often sensitive, salts must encode the deployer's address. This means deployment is permissioned, but still consistent across EVM chains.

## Deployed Contracts

The factory and minimal proxy implementations are deployed at the following addresses:

```solidity
// Proxy Factory
address constant PROXY_FACTORY_ADDRESS = 0x0000000000734F780F5B35C6C72500f4609feC1e;

// Minimal Proxy Implementations
address constant MINIMAL_PROXY_SOLADY_ADDRESS = 0x0000000000354D21D30F6CfECDF569b9fd796ADa;
address constant MINIMAL_PROXY_OZ_ADDRESS = 0x0000000000c110c7599c63EAE0C95e17b41CBb9B;
```

## Usage

```solidity
// reference the deployed proxy factory
ProxyFactory factory = ProxyFactory(0x0000000000eeC2Ee9058EFD20f5Db178E08e39D6);
// reference the minimal proxy implementation
address implementation = 0x0000000000354D21D30F6CfECDF569b9fd796ADa; // Solady implementation

// To derive a salt, encode the deployer's address into the top 160 bits of the salt, followed by 96 bits of "actual" salt.
address deployer = msg.sender;
uint96 actualSalt = 1; // can be any uint96 value
bytes32 salt = bytes32((uint256(uint160(deployer)) << 96) | uint96(actualSalt));
bytes memory initData = abi.encodeWithSignature("initialize(address)", msg.sender);

// Deploy a proxy (with optional immutable args)
bytes memory immutableArgs = ""; // If empty, deploys a normal proxy
address proxy = factory.deploy(implementation, salt, initData, immutableArgs);

// Deploy a clone (ERC-1167 minimal proxy)
address clone = factory.clone(implementation, salt, initData, immutableArgs);

// Deploy a beacon proxy
address beacon = 0x...; // your beacon contract address
address beaconProxy = factory.deployBeaconProxy(beacon, salt, initData, immutableArgs);

// Get the initcode hash for various proxies
bytes32 proxyInitcodeHash = factory.getInitcodeHashForProxy(implementation, immutableArgs);
bytes32 cloneInitcodeHash = factory.getInitcodeHashForClone(implementation, immutableArgs);
bytes32 beaconProxyInitcodeHash = factory.getInitcodeHashForBeaconProxy(beacon, immutableArgs);
```

## Features

-   Deterministic deployment of ERC1967 proxies, beacon proxies, and clones
-   Support for immutable args in all proxy types
-   Permission control via deployer address encoded in salt
-   Consistent addresses across all EVM chains
