// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import "forge-std/Test.sol";
import "forge-std/Vm.sol";

import "src/RewardDistributor.sol";
import {IRewardDistributorDef} from "src/interfaces/IRewardDistributor.sol";

contract RenderEngineTest is Test, IRewardDistributorDef {
    RewardDistributor rd;
    address _owner = address(2);

    function setUp() public {
        rd = new RewardDistributor(_owner);
    }

    function testSetZeroRootFail() public {
        vm.expectRevert(ZeroRootSet.selector);
        rd.setMerkleRoot(bytes32(0));
    }

    function testSetRootTwiceFail(bytes32 root) public {
        vm.assume(root != bytes32(0));
        vm.startPrank(_owner);
        rd.setMerkleRoot(root);

        vm.expectRevert(RootSetTwice.selector);

        rd.setMerkleRoot(root);
    }

    function testClaim() public {}
}
