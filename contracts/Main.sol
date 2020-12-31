// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;
import "./Ownable.sol";

contract Main is Ownable {
    constructor(address chairMan_) public {
        chairMan = chairMan_;
        registeredVoter[chairMan] = true;
        numberOfVoters += 1;
    }

    address public chairMan;
}
