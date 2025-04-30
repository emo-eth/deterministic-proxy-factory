/// SPDX-License-Identifier: MIT

import { MyContract } from "./MyContract.sol";
import { PermissionedSalt } from "deterministic-proxy-factory/PermissionedSalt.sol";
import {
    DeterministicProxyFactory,
    DeterministicProxyFactoryFixture
} from "deterministic-proxy-factory/fixtures/DeterministicProxyFactoryFixture.sol";
import {
    MinimalUpgradeableProxyOZ,
    MinimalUpgradeableProxyOZFixture
} from "deterministic-proxy-factory/fixtures/MinimalUpgradeableProxyOZFixture.sol";
import {
    MinimalUpgradeableProxySolady,
    MinimalUpgradeableProxySoladyFixture
} from "deterministic-proxy-factory/fixtures/MinimalUpgradeableProxySoladyFixture.sol";
import { Test } from "forge-std/Test.sol";

contract MyContractTest is Test {

    DeterministicProxyFactory factory;
    MyContract myContract;

    function setUp() public {
        // Convenience methods to deploy the factory and minimal proxies to their appropriate
        // addresses as part of setup
        factory = DeterministicProxyFactory(
            DeterministicProxyFactoryFixture.setUpDeterministicProxyFactory()
        );
        address minimalProxyOZ = MinimalUpgradeableProxyOZFixture.setUpMinimalUpgradeableProxyOZ();
        address minimalProxySolady =
            MinimalUpgradeableProxySoladyFixture.setUpMinimalUpgradeableProxySolady();

        // if all you need is a UUPS proxy, you can use the deterministicProxy methods to deploy
        // your contract in two steps
        // (first deploy your implementation, then deploy + upgrade the proxy to your
        // implementation)
        MyContract myContractImplementation = new MyContract();
        myContract = MyContract(
            DeterministicProxyFactoryFixture.deterministicProxyOZ({
                initialProxySalt: PermissionedSalt.createPermissionedSalt(
                    address(this), uint96(vm.envOr("SALT", uint256(0)))
                ),
                initialOwner: address(this),
                implementation: address(myContractImplementation),
                callData: abi.encodeCall(MyContract.reinitialize, (address(this)))
            })
        );

        // above, using solady
        myContract = MyContract(
            DeterministicProxyFactoryFixture.deterministicProxySolady({
                initialProxySalt: PermissionedSalt.createPermissionedSalt(
                    address(this), uint96(vm.envOr("SALT", uint256(0)))
                ),
                initialOwner: address(this),
                implementation: address(myContractImplementation),
                callData: abi.encodeCall(MyContract.reinitialize, (address(this)))
            })
        );
    }

    // write your tests here

}
