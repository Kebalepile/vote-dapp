// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;
import "./Proxy.sol";

contract Ownable is Proxy {
    address public owner;

    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }
}
