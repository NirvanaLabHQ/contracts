// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import "forge-std/Test.sol";
import "src/lib/FastArray.sol";

contract FastArrayTest is Test {
    FastArray.Data private fastArray;

    function testInsert() public {
        FastArray.insert(fastArray, 10);
        vm.expectRevert("remove value not exist");
        FastArray.remove(fastArray, 100);

        FastArray.remove(fastArray, 10);
        uint256 value = FastArray.get(fastArray, 0);
        assertEq(value, 0);
    }

    function testRemoveFromEmptyArray() public {
        vm.expectRevert("can not remove from empty array");
        FastArray.remove(fastArray, 100);
    }

    function testRemoveItemNotExist() public {
        FastArray.insert(fastArray, 10);
        FastArray.insert(fastArray, 50);

        vm.expectRevert("remove value not exist");
        FastArray.remove(fastArray, 100);
    }
}
