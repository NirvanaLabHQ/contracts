// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import {RBT} from "src/RBT.sol";
import "forge-std/Test.sol";

library Utils {
    Vm private constant vm =
        Vm(address(uint160(uint256(keccak256("hevm cheat code")))));

    function deployRBT(address owner) public returns (RBT token) {
        token = new RBT();
        token.initialize("REBORN", "RBT", 10**10 * 1 ether, owner);

        // auto set owner as minter
        vm.prank(owner);
        address[] memory minterToAdd = new address[](1);
        minterToAdd[0] = owner;
        address[] memory minterToRemove;
        token.updateMinter(minterToAdd, minterToRemove);
    }
}
