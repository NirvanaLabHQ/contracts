// SPDX-License-Identifier: GPL-3.0-only
pragma solidity 0.8.17;

import "forge-std/console.sol";

library CompactArray {
    struct Array {
        uint256[] _data;
        uint256 length;
    }

    function initialize(Array storage array, uint256 length) internal {
        array.length = length;
        array._data = new uint256[](13);
    }

    // function encodeUint32Array(uint32[] memory values)
    //     public
    //     pure
    //     returns (uint256[] memory bs)
    // {
    //     bs = new uint256[](13);
    //     for (uint256 i = 0; i < values.length; i++) {
    //         bs[i / 8] = uint256(abi.encodePacked(bs[i / 8], values[i]));
    //     }
    // }

    // function write(Array storage array, uint32[] memory values) internal {
    //     require(values.length == array.length, "length not match");
    //     array._data = encodeUint32Array(values);
    // }

    function readAll(Array memory array)
        internal
        pure
        returns (uint32[] memory values)
    {
        values = new uint32[](array.length);
        for (uint32 i = 0; i < array.length; i++) {
            values[i] = read(array, i);
        }
    }

    function readData(Array memory array)
        internal
        pure
        returns (uint256[] memory)
    {
        return array._data;
    }

    function read(Array memory array, uint256 index)
        internal
        pure
        returns (uint32 x)
    {
        uint256 bucket = index >> 3;
        uint256 offset = (7 - (index % 8)) * 32;
        uint256 mask = 0xffffffff << offset;
        return uint32((array._data[bucket] & mask) >> offset);

        // bytes memory bs = abi.encodePacked(
        //     array._data[index * 3],
        //     array._data[index * 3 + 1],
        //     array._data[index * 3 + 2]
        // );
        // assembly {
        //     x := mload(add(bs, 0x3))
        // }
    }

    function set(
        Array storage array,
        uint256 index,
        uint32 value
    ) internal {
        uint256 bucket = index >> 3;
        // uint256 mask = 1 << (index & 0xff);
        uint256 mask = uint256(value) << ((7 - (index % 8)) * 32);
        array._data[bucket] |= mask;
        // array._data
        // unchecked {
        //     array._data[index * 3] = bs[0];
        //     array._data[index * 3 + 1] = bs[1];
        //     array._data[index * 3 + 2] = bs[2];
        // }
    }

    /**
     * @dev convert memory bytes to uint256
     */
    function sliceUint(bytes memory bs, uint256 start)
        internal
        pure
        returns (uint256 x)
    {
        require(bs.length >= start + 32, "slicing out of range");
        assembly {
            x := mload(add(bs, add(0x20, start)))
        }
    }
}
