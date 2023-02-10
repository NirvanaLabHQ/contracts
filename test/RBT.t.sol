// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import "forge-std/Test.sol";
import "forge-std/Vm.sol";
import {Utils} from "test/Utils.sol";
import {DeployProxy} from "foundry-upgrades/utils/DeployProxy.sol";

import "src/RBT.sol";
import {IRebornTokenDef} from "src/interfaces/IRebornToken.sol";

contract RBTTest is Test, IRebornTokenDef {
    RBT token;
    DeployProxy internal _deployProxy;
    address owner = address(2);
    address user = address(20);
    address minter = address(30);

    event Transfer(address indexed from, address indexed to, uint256 value);

    function setUp() public {
        token = Utils.deployRBT(owner);
        vm.prank(owner);
        address[] memory minterToAdd = new address[](1);
        minterToAdd[0] = minter;
        address[] memory minterToRemove;
        token.updateMinter(minterToAdd, minterToRemove);
    }

    /** minter can mint token if it's not enough */
    function testMinterCanMint(uint256 amount) public {
        vm.assume(amount <= token.cap());
        vm.expectEmit(true, true, true, true);
        emit Transfer(address(0), user, amount);

        vm.prank(minter);
        token.mint(user, amount);
    }

    /**
     * @dev not owner cannot mint token
     */
    function testNotOwnerCannotMint(address caller, uint256 amount) public {
        vm.assume(caller != owner);
        vm.assume(amount <= token.cap());
        vm.expectRevert(NotMinter.selector);
        vm.prank(caller);
        token.mint(caller, amount);
    }

    /**
     * @dev cannot mint token excced the cap
     */
    function testCannotExceedCap(uint256 amount) public {
        vm.assume(amount > token.cap());
        vm.expectRevert("ERC20Capped: cap exceeded");
        vm.prank(owner);
        token.mint(user, amount);
    }
}
