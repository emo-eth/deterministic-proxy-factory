# Deterministic Proxy Factory

This is a simple deterministic proxy factory that allows you to deploy deterministic ERC1967 proxies and beacon proxies. Since initialization calls are often sensitive, salts must encode the deployer's address. This means deployment is permissioned, but still consistent across EVM chains.

## Usage

```solidity
// assuming proxy factory has been deployed via the keyless create2 factory
ProxyFactory factory = ProxyFactory(0x0000000000Db69BB2e1FdE2720A300e5608Bbc05);
// assuming the minimal proxy implementation has already been deployed
MinimalUpgradeableProxySolady implementation = MinimalUpgradeableProxySolady(0x0000000000123FE8f366520c6619900f460C84Fa);

// To derive a salt, encode the deployer's address into the top 160 bits of the salt, followed by 96 bits of "actual" salt.
address deployer = ...;
uint96 actualSalt = ...;
bytes32 salt = bytes32((uint256(uint160(deployer)) << 96) | uint96(actualSalt));
address initialOwner = ...;
bytes memory initData = abi.encodeWithSignature("initialize(address)", initialOwner);

// Deploy a proxy
factory.deploy(address(implementation), salt, initData);

// Deploy a beacon proxy
factory.deployBeaconProxy(beacon, salt, initData);

// Get the initcode hash for a proxy
bytes32 proxyInitcodeHash = factory.getInitcodeHashForProxy(implementation);

// Get the initcode hash for a beacon proxy
bytes32 beaconProxyInitcodeHash = factory.getInitcodeHashForBeaconProxy(beacon);
```
