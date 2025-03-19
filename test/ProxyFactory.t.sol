// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { Test, console2 } from "forge-std/Test.sol";
import { VmSafe } from "forge-std/Vm.sol";

import { LibClone } from "solady/utils/LibClone.sol";
import { ProxyFactory } from "src/ProxyFactory.sol";

// Simple implementation contract for testing
contract MockImplementation {

    uint256 public value;

    event ValueSet(uint256 value);

    function setValue(uint256 _value) external {
        value = _value;
        emit ValueSet(_value);
    }

    function initialize(uint256 _value) external {
        value = _value;
        emit ValueSet(_value);
    }

}

// Simple beacon contract for testing
contract MockBeacon {

    address private _implementation;

    constructor(address implementation_) {
        _implementation = implementation_;
    }

    function implementation() external view returns (address) {
        return _implementation;
    }

}

contract ProxyFactoryTest is Test {

    ProxyFactory factory;
    MockImplementation implementation;
    MockBeacon beacon;

    address deployer;
    address user;

    function setUp() public {
        factory = new ProxyFactory();
        implementation = new MockImplementation();
        beacon = new MockBeacon(address(implementation));

        deployer = makeAddr("deployer");
        user = makeAddr("user");
    }

    function _createSalt(address _deployer) internal pure returns (bytes32) {
        return bytes32(uint256(uint160(_deployer)) << 96);
    }

    function test_deploy() public {
        vm.startPrank(deployer);

        bytes32 salt = _createSalt(deployer);
        bytes memory initData = abi.encodeCall(MockImplementation.initialize, (42));

        // Use the correct prediction function for ERC1967 proxies
        address expectedAddress = LibClone.predictDeterministicAddressERC1967(
            address(implementation), salt, address(factory)
        );

        address proxy = factory.deploy(address(implementation), salt, initData);

        assertEq(proxy, expectedAddress);
        assertEq(MockImplementation(proxy).value(), 42);

        vm.stopPrank();
    }

    function test_deploy_withValue(uint256 ethValue) public {
        ethValue = bound(ethValue, 0.001 ether, 10 ether);

        vm.deal(deployer, ethValue);
        vm.startPrank(deployer);

        bytes32 salt = _createSalt(deployer);
        bytes memory initData = abi.encodeCall(MockImplementation.initialize, (123));

        address proxy = factory.deploy{ value: ethValue }(address(implementation), salt, initData);

        assertEq(address(proxy).balance, ethValue);
        assertEq(MockImplementation(proxy).value(), 123);

        vm.stopPrank();
    }

    function test_deploy_emitsEvent() public {
        vm.startPrank(deployer);

        bytes32 salt = _createSalt(deployer);
        bytes memory initData = abi.encodeCall(MockImplementation.setValue, (999));

        // Test event emission by listening for the MockImplementation event
        vm.expectEmit(true, true, true, true);
        emit MockImplementation.ValueSet(999);

        factory.deploy(address(implementation), salt, initData);

        vm.stopPrank();
    }

    function test_deploy_withoutCallData() public {
        vm.startPrank(deployer);

        bytes32 salt = _createSalt(deployer);
        bytes memory emptyCallData = "";

        address proxy = factory.deploy(address(implementation), salt, emptyCallData);

        // Value should be zero since no initialization was done
        assertEq(MockImplementation(proxy).value(), 0);

        vm.stopPrank();
    }

    function test_deploy_fail_InvalidDeployer() public {
        vm.startPrank(user);

        // Try to deploy with deployer's address in salt while calling from user
        bytes32 salt = _createSalt(deployer);
        bytes memory initData = abi.encodeCall(MockImplementation.initialize, (42));

        vm.expectRevert(ProxyFactory.InvalidDeployer.selector);
        factory.deploy(address(implementation), salt, initData);

        vm.stopPrank();
    }

    function test_deploy_fail_ProxyCallFailed() public {
        vm.startPrank(deployer);

        bytes32 salt = _createSalt(deployer);

        // Create invalid calldata that will revert
        bytes memory invalidCallData = abi.encodeWithSignature("nonExistentFunction()");

        vm.expectRevert(ProxyFactory.ProxyCallFailed.selector);
        factory.deploy(address(implementation), salt, invalidCallData);

        vm.stopPrank();
    }

    function test_deployBeaconProxy() public {
        vm.startPrank(deployer);

        bytes32 salt = _createSalt(deployer);
        bytes memory initData = abi.encodeCall(MockImplementation.initialize, (42));

        address expectedAddress = LibClone.predictDeterministicAddressERC1967BeaconProxy(
            address(beacon), salt, address(factory)
        );

        address proxy = factory.deployBeaconProxy(address(beacon), salt, initData);

        assertEq(proxy, expectedAddress);
        assertEq(MockImplementation(proxy).value(), 42);

        vm.stopPrank();
    }

    function test_deployBeaconProxy_withValue(uint256 ethValue) public {
        ethValue = bound(ethValue, 0.001 ether, 10 ether);

        vm.deal(deployer, ethValue);
        vm.startPrank(deployer);

        bytes32 salt = _createSalt(deployer);
        bytes memory initData = abi.encodeCall(MockImplementation.initialize, (123));

        address proxy =
            factory.deployBeaconProxy{ value: ethValue }(address(beacon), salt, initData);

        assertEq(address(proxy).balance, ethValue);
        assertEq(MockImplementation(proxy).value(), 123);

        vm.stopPrank();
    }

    function test_deployBeaconProxy_emitsEvent() public {
        vm.startPrank(deployer);

        bytes32 salt = _createSalt(deployer);
        bytes memory initData = abi.encodeCall(MockImplementation.setValue, (999));

        // Test event emission
        vm.expectEmit(true, true, true, true);
        emit MockImplementation.ValueSet(999);

        factory.deployBeaconProxy(address(beacon), salt, initData);

        vm.stopPrank();
    }

    function test_deployBeaconProxy_withoutCallData() public {
        vm.startPrank(deployer);

        bytes32 salt = _createSalt(deployer);
        bytes memory emptyCallData = "";

        address proxy = factory.deployBeaconProxy(address(beacon), salt, emptyCallData);

        // Value should be zero since no initialization was done
        assertEq(MockImplementation(proxy).value(), 0);

        vm.stopPrank();
    }

    function test_deployBeaconProxy_fail_InvalidDeployer() public {
        vm.startPrank(user);

        // Try to deploy with deployer's address in salt while calling from user
        bytes32 salt = _createSalt(deployer);
        bytes memory initData = abi.encodeCall(MockImplementation.initialize, (42));

        vm.expectRevert(ProxyFactory.InvalidDeployer.selector);
        factory.deployBeaconProxy(address(beacon), salt, initData);

        vm.stopPrank();
    }

    function test_deployBeaconProxy_fail_ProxyCallFailed() public {
        vm.startPrank(deployer);

        bytes32 salt = _createSalt(deployer);

        // Create invalid calldata that will revert
        bytes memory invalidCallData = abi.encodeWithSignature("nonExistentFunction()");

        vm.expectRevert(ProxyFactory.ProxyCallFailed.selector);
        factory.deployBeaconProxy(address(beacon), salt, invalidCallData);

        vm.stopPrank();
    }

    function test_validateSalt(bytes32 salt) public {
        // Extract the deployer address from the salt
        address extractedDeployer = address(uint160(uint256(salt) >> 96));

        // Ensure we're calling from the extracted deployer address
        vm.startPrank(extractedDeployer);

        // We can't directly test internal functions, so we test it through deploy
        bytes memory emptyCallData = "";

        // This should succeed as the deployer addresses match
        factory.deploy(address(implementation), salt, emptyCallData);

        vm.stopPrank();
    }

    function test_validateSalt_fail_InvalidDeployer(bytes32 salt, address wrongDeployer) public {
        vm.assume(address(uint160(uint256(salt) >> 96)) != wrongDeployer);

        vm.startPrank(wrongDeployer);

        // This should fail as the deployer addresses don't match
        vm.expectRevert(ProxyFactory.InvalidDeployer.selector);
        factory.deploy(address(implementation), salt, "");

        vm.stopPrank();
    }

    function test_deployTwice_fail_ProxyDeploymentFailed() public {
        vm.startPrank(deployer);
        bytes32 salt = _createSalt(deployer);
        bytes memory initData = abi.encodeCall(MockImplementation.initialize, (42));

        factory.deploy(address(implementation), salt, initData);

        vm.expectRevert(abi.encodeWithSignature("DeploymentFailed()"));
        factory.deploy(address(implementation), salt, initData);
    }

    function test_getInitcodeHashForProxy() public view {
        address testImplementation = address(implementation);

        // Get the initcode hash from the factory
        bytes32 factoryHash = factory.getInitcodeHashForProxy(testImplementation);

        // Get the initcode hash directly from LibClone
        bytes32 expectedHash = LibClone.initCodeHashERC1967(testImplementation);

        // Verify they match
        assertEq(factoryHash, expectedHash);
    }

    function test_getInitcodeHashForBeaconProxy() public view {
        address testBeacon = address(beacon);

        // Get the initcode hash from the factory
        bytes32 factoryHash = factory.getInitcodeHashForBeaconProxy(testBeacon);

        // Get the initcode hash directly from LibClone
        bytes32 expectedHash = LibClone.initCodeHashERC1967BeaconProxy(testBeacon);

        // Verify they match
        assertEq(factoryHash, expectedHash);
    }

}
