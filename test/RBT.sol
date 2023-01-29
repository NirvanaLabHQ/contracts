// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "forge-std/Vm.sol";
import {DeployProxy} from "foundry-upgrades/utils/DeployProxy.sol";

import "src/RBT.sol";

contract TokenTest is Test {
    RBT token;
    DeployProxy internal _deployProxy;
    address owner = address(2);
    address user = address(20);

    event Transfer(address indexed from, address indexed to, uint256 value);

    function setUp() public {
        /// @dev deploy deployProxy tool
        _deployProxy = new DeployProxy();
        RBT tokenImpl = new RBT();
        bytes memory initData = abi.encodeWithSelector(
            RBT.initialize.selector,
            "REBORN",
            "RBT",
            10**10 * 1 ether,
            owner
        );
        token = RBT(
            _deployProxy.deployErc1967Proxy(address(tokenImpl), initData)
        );
    }

    /** owner can mint token if it's not enough */
    function testOwnerCanMint(uint256 amount) public {
        vm.assume(amount <= token.cap());
        vm.expectEmit(true, true, true, true);
        emit Transfer(address(0), user, amount);

        vm.prank(owner);
        token.mint(user, amount);
    }

    /**
     * @dev not owner cannot mint token
     */
    function testNotOwnerCannotMint(address caller, uint256 amount) public {
        vm.assume(caller != owner);
        vm.expectRevert("SafeOwnable: caller not owner");
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
