// SPDX-License-Identifier: GPL-3.0-only
pragma solidity 0.8.17;

import "forge-std/console.sol";

library CompactArray {
    struct Array {
        bytes _data;
        uint256 length;
    }

    function initialize(Array storage array, uint256 length) internal {
        array.length = length;
        array._data = encodeUint24Array(new uint24[](length));
    }

    function encodeUint24Array(uint24[] memory values)
        public
        returns (bytes memory bs)
    {
        for (uint256 i = 0; i < values.length; i++) {
            bs = abi.encodePacked(bs, values[i]);
        }
    }

    function write(Array storage array, uint24[] memory values) internal {
        require(values.length == array.length, "length not match");
        array._data = encodeUint24Array(values);
    }

    function readAll(Array memory array)
        internal
        returns (uint24[] memory values)
    {
        values = new uint24[](array.length);
        for (uint32 i = 0; i < array.length; i++) {
            values[i] = read(array, i);
        }
    }

    function readData(Array memory array) internal pure returns (bytes memory) {
        return array._data;
    }

    function read(Array memory array, uint256 index)
        internal
        returns (uint24 x)
    {
        bytes memory bs = abi.encodePacked(
            array._data[index * 3],
            array._data[index * 3 + 1],
            array._data[index * 3 + 2]
        );
        assembly {
            x := mload(add(bs, 0x3))
        }
    }

    function set(
        Array storage array,
        uint256 index,
        uint24 value
    ) internal {
        bytes memory bs = abi.encodePacked(value);
        array._data[index * 3] = bs[0];
        array._data[index * 3 + 1] = bs[1];
        array._data[index * 3 + 2] = bs[2];
    }

    /**
     * @dev convert memory bytes to uint256
     */
    function sliceUint(bytes memory bs, uint256 start)
        internal
        pure
        returns (uint256)
    {
        require(bs.length >= start + 32, "slicing out of range");
        uint256 x;
        assembly {
            x := mload(add(bs, add(0x20, start)))
        }
        return x;
    }
}
