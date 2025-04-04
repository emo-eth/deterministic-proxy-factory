# Deterministic Proxy Factory

This is a simple deterministic proxy factory that allows you to deploy deterministic ERC1967 proxies, beacon proxies, and clones (ERC-1167 minimal proxies). Since initialization calls are often sensitive, salts must encode the deployer's address. This means deployment is permissioned, but still consistent across EVM chains.

## Features

-   Deterministic deployment of ERC1967 proxies, beacon proxies, and clones
-   Support for immutable args in all proxy types
-   Permission control via deployer address encoded in salt
-   Consistent addresses across all EVM chains

## Rationalization

Permissionless, non-upgradeable protocols like [Seaport](https://etherscan.io/address/0x0000000000000068f116a894984e2db1123eb395#code) or the [Delegate Registry](https://etherscan.io/address/0x00000000000000447e69651d841bd8d104bed493) are often deployed to consistent, deterministic addresses accross chains using [Nick Johnson's Keyless Create Factory](https://etherscan.io/address/0x4e59b44847b379578588920ca78fbf26c0b4956c#code) or 0age's [ImmutableCreate2Factory](https://etherscan.io/address/0x0000000000ffe8b47b3e2130213b802212439497#code).

Both factories use the [`CREATE2` opcode](https://www.evm.codes/?fork=cancun#f5) which hash the initialization code of the contract with a "salt" value to determine the resulting address. This is fine for immutable contracts, but since upgradeable contracts can change over time, it is not always desirable to use the same initialization code over time. This is especially true because upgradeable contracts require initialization data that is separate from a contract's bytecode. This data often sets the contract owner or admin authority, and must be provided in a separate call.

The `ProxyFactory` uses the `ImmutableCreate2Factory` strategy of encoding the deployer's address into the salt, which allows for permissioned deploys while still being deterministic. The `ProxyFactory` also accepts optional calldata for an initialization call, which is passed to the proxy after deployment to its deterministic address.

Support for [ClonesWithImmutableArgs](https://github.com/wighawag/clones-with-immutable-args)-style "immutable arguments" is also included, but they are not forwarded to the implementation contract by default. Instead, they are appended to the bytecode of the proxy, but not as calldata to every call to the proxy implementation. See the [LibClone](https://github.com/vectorized/solady/blob/main/src/utils/LibClone.sol) library for more details.

## Deployed Contracts

The factory and minimal proxy implementations are deployed at the following addresses:

```solidity
// Proxy Factory
address constant PROXY_FACTORY_ADDRESS = 0x000000000028301FcDF54db25F5D5C586378D100;

// Minimal Proxy Implementations
address constant MINIMAL_PROXY_SOLADY_ADDRESS = 0x0000000000354D21D30F6CfECDF569b9fd796ADa;
address constant MINIMAL_PROXY_OZ_ADDRESS = 0x0000000000c110c7599c63EAE0C95e17b41CBb9B;
```

## Usage

```solidity
// reference the deployed proxy factory
ProxyFactory factory = DeterministicProxyFactory(0x000000000028301FcDF54db25F5D5C586378D100);
// reference the minimal proxy implementation
address implementation = 0x0000000000354D21D30F6CfECDF569b9fd796ADa; // Solady implementation

// To derive a salt, encode the deployer's address into the top 160 bits of the salt, followed by 96 bits of "actual" salt.
address deployer = msg.sender;
uint96 actualSalt = 1; // can be any uint96 value
// can be created manually
bytes32 salt = bytes32((uint256(uint160(deployer)) << 96) | uint96(actualSalt));
// or using the PermissionedSalt library
bytes32 sameSalt = PermissionedSalt.createPermissionedSalt(deployer, actualSalt);

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

## FAQ

### Why not use the keyless Create2 factory?

It does not support permissioned deploys.

### Why not use the ImmutableCreate2Factory?

It does not support initialization calls.

### Why not wrap a call to the ImmutableCreate2Factory in another contract that makes an initialization call?

Solady's LibClone library has painstakingly optimized proxy/clone/beacon proxy bytecode, which gets loaded into memory as part of the deployment process. Rather than try to tweak the logic so it works with external calls, it's easier, safer, and more gas efficient to just have the factory deploy the proxies in addition to call their initialization methods. This approach saves gas by avoiding an extra external call and maintains the optimized bytecode patterns.

### When should I use immutable args vs initialization data?

Immutable args are best used for values that:

1. Never change throughout the contract's lifetime
2. Are frequently accessed (since reading from bytecode is cheaper than storage)
3. Are the same across all chains where the proxy is deployed

Initialization data is better for:

1. Values that might need to change (via upgrade)
2. Chain-specific configuration
3. Complex setup logic that needs to be executed
