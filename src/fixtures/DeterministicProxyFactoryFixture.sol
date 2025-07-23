// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import {
    MINIMAL_PROXY_OZ_ADDRESS,
    MINIMAL_PROXY_SOLADY_ADDRESS,
    MINIMAL_UUPS_UPGRADEABLE_ADDRESS,
    PROXY_FACTORY_ADDRESS,
    PROXY_FACTORY_SALT
} from "../Constants.sol";
import { DeterministicProxyFactory } from "../DeterministicProxyFactory.sol";

import {
    MinimalUUPSUpgradeable,
    MinimalUUPSUpgradeableFixture
} from "./MinimalUUPSUpgradeableFixture.sol";
import {
    MinimalUpgradeableProxyOZ,
    MinimalUpgradeableProxyOZFixture
} from "./MinimalUpgradeableProxyOZFixture.sol";
import {
    MinimalUpgradeableProxySolady,
    MinimalUpgradeableProxySoladyFixture
} from "./MinimalUpgradeableProxySoladyFixture.sol";
import { UUPSUpgradeable } from "solady/utils/UUPSUpgradeable.sol";

/**
 * @title DeterministicProxyFactoryFixture
 * @notice Test fixture for deploying the DeterministicProxyFactory. Import and use in setUp().
 */
library DeterministicProxyFactoryFixture {

    error CallDataRequired();

    bytes constant PROXY_FACTORY_INITCODE =
        hex"60808060405234601557610b00908161001a8239f35b5f80fdfe60806040526004361015610011575f80fd5b5f3560e01c80632e21ae031461042e57806333722ce014610415578063c020d871146102b5578063da91c54f14610099578063decbdad4146100805763e0d51fdc1461005b575f80fd5b3461007c57602061007461006e366105e6565b9161098f565b604051908152f35b5f80fd5b3461007c576020610074610093366105e6565b916108d1565b6100a236610551565b6100af8594969395610abf565b80156101f9576100c560169260759236916106fc565b6040519381518092816020608b8901920160045afa507fb3582b35133d50545afa5036515af43d6000803e604d573d6000fd5b3d6000f3606b8601527f1b60e01b36527fa3f0ad74e5423aebfd80d3ef4346578335a9a72aeaee59ff6c604b8601527660195155f3363d3d373d3d363d602036600436635c60da602b86015260148501528060381b6afe6100523d8160233d39730161ffad821185015201910134f580156101ec57915b81610196575b60208373ffffffffffffffffffffffffffffffffffffffff60405191168152f35b815f9291839260405192839283378101838152039082855af16101b761072c565b50156101c4578180610175565b7fe9349fdc000000000000000000000000000000000000000000000000000000005f5260045ffd5b63301164255f526004601cfd5b50509073ffffffffffffffffffffffffffffffffffffffff604051927fb3582b35133d50545afa5036515af43d6000803e604d573d6000fd5b3d6000f36060527f1b60e01b36527fa3f0ad74e5423aebfd80d3ef4346578335a9a72aeaee59ff6c6040527660195155f3363d3d373d3d363d602036600436635c60da602052167c60523d8160223d39730000000000000000000000000000000000000000176009526074600c34f59081156101ec576040525f6060529161016f565b6102be36610551565b6102cb8594969395610abf565b8015610396576060916102df9136916106fc565b6040519281518092816020868801920160045afa507fcc3735a920a3ca505d382bbc545af43d6000803e6038573d6000fd5b3d6000f360408501527f5155f3363d3d373d3d363d7f360894a13ba1a3210667c828492db98dca3e207660208501526160096016526014528060381b6afe61003d3d8160233d39730161ffc28211526016518352019034f580156101ec5791816101965760208373ffffffffffffffffffffffffffffffffffffffff60405191168152f35b505090604051917fcc3735a920a3ca505d382bbc545af43d6000803e6038573d6000fd5b3d6000f36060527f5155f3363d3d373d3d363d7f360894a13ba1a3210667c828492db98dca3e2076604052616009602052601e5268603d3d8160223d3973600a52605f602134f59081156101ec576040525f6060529161016f565b3461007c576020610074610428366105e6565b91610751565b61043736610551565b6104448594969395610abf565b80156104e057600b916104589136916106fc565b91604051908351809481602060438601920160045afa506e5af43d82803e903d91602b57fd5bf3602383015260148201528260881b74fe61002d3d81600a3d39f3363d3d373d3d3d363d7301815261ffd3603784019310010134f580156101ec5791816101965760208373ffffffffffffffffffffffffffffffffffffffff60405191168152f35b50506c5af43d3d93803e602a57fd5bf360215260145273602c3d8160093d39f33d3d3d3d363d3d37363d735f526035600c34f580156101ec575f6021529161016f565b9181601f8401121561007c5782359167ffffffffffffffff831161007c576020838186019501011161007c57565b60807ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffc82011261007c5760043573ffffffffffffffffffffffffffffffffffffffff8116810361007c57916024359160443567ffffffffffffffff811161007c57816105bf91600401610523565b929092916064359067ffffffffffffffff821161007c576105e291600401610523565b9091565b9060407ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffc83011261007c5760043573ffffffffffffffffffffffffffffffffffffffff8116810361007c57916024359067ffffffffffffffff821161007c576105e291600401610523565b907fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe0601f604051930116820182811067ffffffffffffffff82111761069557604052565b7f4e487b71000000000000000000000000000000000000000000000000000000005f52604160045260245ffd5b67ffffffffffffffff811161069557601f017fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe01660200190565b92919261071061070b836106c2565b610651565b938285528282011161007c57815f926020928387013784010152565b3d1561074c573d9061074061070b836106c2565b9182523d5f602084013e565b606090565b91908161080957505073ffffffffffffffffffffffffffffffffffffffff604051917fb3582b35133d50545afa5036515af43d6000803e604d573d6000fd5b3d6000f36060527f1b60e01b36527fa3f0ad74e5423aebfd80d3ef4346578335a9a72aeaee59ff6c6040527660195155f3363d3d373d3d363d602036600436635c60da602052167c60523d8160223d39730000000000000000000000000000000000000000176009526074600c20906040525f60605290565b6108149136916106fc565b6040519181519161ffad83113d3d3e5f5b8381106108bb5750506016916075917fb3582b35133d50545afa5036515af43d6000803e604d573d6000fd5b3d6000f3606b8601527f1b60e01b36527fa3f0ad74e5423aebfd80d3ef4346578335a9a72aeaee59ff6c604b8601527660195155f3363d3d373d3d363d602036600436635c60da602b86015260148501528060381b696100523d8160233d39730184520191012090565b806020809284010151608b828801015201610825565b9190816109115750506c5af43d3d93803e602a57fd5bf360215260145273602c3d8160093d39f33d3d3d3d363d3d37363d735f526035600c205f60215290565b61091c9136916106fc565b6040519181519161ffd283113d3d3e5f5b838110610979575050600c916037916e5af43d82803e903d91602b57fd5bf3602386015260148501528060881b7361002d3d81600a3d39f3363d3d373d3d3d363d730184520191012090565b806020809284010151604382880101520161092d565b929180610a0b57505090604051907fcc3735a920a3ca505d382bbc545af43d6000803e6038573d6000fd5b3d6000f36060527f5155f3363d3d373d3d363d7f360894a13ba1a3210667c828492db98dca3e2076604052616009602052601e5268603d3d8160223d3973600a52605f602120906040525f60605290565b90610a179136916106fc565b916040519083519061ffc282113d3d3e5f5b828110610aa95750829394507fcc3735a920a3ca505d382bbc545af43d6000803e6038573d6000fd5b3d6000f3604060609401527f5155f3363d3d373d3d363d7f360894a13ba1a3210667c828492db98dca3e207660208501526160096016526014528060381b6961003d3d8160233d3973015f52601651835201902090565b8060208092880101516060828701015201610a29565b339060601c03610acb57565b7f043c669f000000000000000000000000000000000000000000000000000000005f5260045ffdfea164736f6c634300081d000a";

    address constant CREATE2_FACTORY = 0x4e59b44847b379578588920cA78FbF26c0B4956C;
    DeterministicProxyFactory internal constant DETERMINISTIC_PROXY_FACTORY =
        DeterministicProxyFactory(PROXY_FACTORY_ADDRESS);

    function setUpDeterministicProxyFactory() internal returns (address) {
        if (address(DETERMINISTIC_PROXY_FACTORY).code.length > 0) {
            return PROXY_FACTORY_ADDRESS;
        }
        (bool success, bytes memory result) =
            CREATE2_FACTORY.call(abi.encodePacked(PROXY_FACTORY_SALT, PROXY_FACTORY_INITCODE));
        bytes20 resultBytes;
        /// @solidity memory-safe-assembly
        assembly {
            resultBytes := mload(add(result, 0x20))
        }
        address resultAddress = address(resultBytes);
        require(success, "Failed to deploy DeterministicProxyFactory");
        require(
            resultAddress == PROXY_FACTORY_ADDRESS, "DeterministicProxyFactory address mismatch"
        );
        return resultAddress;
    }

    function deterministicProxyOZ(
        bytes32 initialProxySalt,
        address initialOwner,
        address implementation,
        bytes memory callData
    ) internal returns (address) {
        setUpDeterministicProxyFactory();
        MinimalUpgradeableProxyOZFixture.setUpMinimalUpgradeableProxyOZ();
        address initialProxy = DETERMINISTIC_PROXY_FACTORY.deploy({
            implementation: MINIMAL_PROXY_OZ_ADDRESS,
            salt: initialProxySalt,
            callData: abi.encodeCall(MinimalUpgradeableProxyOZ.initialize, (initialOwner)),
            immutableArgs: ""
        });
        MinimalUpgradeableProxyOZ(initialProxy).upgradeToAndCall(implementation, callData);
        return initialProxy;
    }

    function deterministicProxySolady(
        bytes32 initialProxySalt,
        address initialOwner,
        address implementation,
        bytes memory callData
    ) internal returns (address) {
        setUpDeterministicProxyFactory();
        MinimalUpgradeableProxySoladyFixture.setUpMinimalUpgradeableProxySolady();
        address initialProxy = DETERMINISTIC_PROXY_FACTORY.deploy({
            implementation: MINIMAL_PROXY_SOLADY_ADDRESS,
            salt: initialProxySalt,
            callData: abi.encodeCall(MinimalUpgradeableProxySolady.initialize, (initialOwner)),
            immutableArgs: ""
        });
        MinimalUpgradeableProxySolady(initialProxy).upgradeToAndCall(implementation, callData);
        return initialProxy;
    }

    function deterministicProxyUUPS(
        bytes32 initialProxySalt,
        address implementation,
        bytes memory upgradeCallData
    ) internal returns (address) {
        setUpDeterministicProxyFactory();
        require(upgradeCallData.length > 0, CallDataRequired());
        MinimalUUPSUpgradeableFixture.setUpMinimalUUPSUpgradeable();
        address initialProxy = DETERMINISTIC_PROXY_FACTORY.deploy({
            implementation: MINIMAL_UUPS_UPGRADEABLE_ADDRESS,
            salt: initialProxySalt,
            callData: abi.encodeCall(
                UUPSUpgradeable.upgradeToAndCall, (implementation, upgradeCallData)
            ),
            immutableArgs: ""
        });
        return initialProxy;
    }

}
