/// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

contract MyContract {

    address public owner;

    function reinitialize(address _owner) public {
        owner = _owner;
    }

    function setOwner(address _owner) public {
        owner = _owner;
    }

}
