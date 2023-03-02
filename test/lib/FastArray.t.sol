// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import "forge-std/Test.sol";
import "src/lib/FastArray.sol";

contract FastArrayTest is Test {
    FastArray.Data private fastArray;

    function testInsert() public {
        FastArray.insert(fastArray, 10);
        assertEq(FastArray.length(fastArray), 1);

        FastArray.remove(fastArray, 10);
        uint256 value = FastArray.get(fastArray, 0);
        assertEq(value, 0);
        assertEq(FastArray.length(fastArray), 0);

        FastArray.insert(fastArray, 10);
        FastArray.insert(fastArray, 20);
        FastArray.insert(fastArray, 15);
        FastArray.insert(fastArray, 17);
        assertEq(FastArray.length(fastArray), 4);

        FastArray.remove(fastArray, 20);
        assertEq(FastArray.length(fastArray), 3);
        assertEq(FastArray.get(fastArray, 1), 17);

        FastArray.remove(fastArray, 10);
        FastArray.remove(fastArray, 15);
        FastArray.remove(fastArray, 17);
        assertEq(FastArray.length(fastArray), 0);
    }
}
