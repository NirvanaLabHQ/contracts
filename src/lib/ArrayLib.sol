// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

library ArrayLib {
    struct Data {
        uint256[] array;
    }

    modifier checkLength(Data memory data, uint256 index) {
        require(index < data.array.length, "index out of bounds");
        _;
    }

    function insert(Data storage data, uint256 value) internal {
        data.array.push(value);
    }

    function remove(
        Data storage data,
        uint256 index
    ) internal checkLength(data, index) {
        require(index < data.array.length, "index out of bounds");
        data.array[index] = data.array[data.array.length - 1];
        data.array.pop();
    }

    function removeValue(Data storage data, uint256 value) internal {
        uint256 index = 0;
        while (index < data.array.length) {
            if (data.array[index] == value) {
                data.array[index] = 0;
            }
            index++;
        }
    }

    function get(
        Data memory data,
        uint256 index
    ) internal pure checkLength(data, index) returns (uint256) {
        return data.array[index];
    }
}
