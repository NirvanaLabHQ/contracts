// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.17;

// A simple array that supports insert and removal.
// The values are assumed to be unique and the library is meant to be lightweight.
// So when calling insert or remove, the caller is responsible to know whether a value already exists in the array or not.
library FastArray {
    struct Data {
        mapping(uint256 => uint256) array;
        mapping(uint256 => uint256) indexMap;
        uint256 length;
    }

    function insert(Data storage _fastArray, uint256 _value) internal {
        _fastArray.array[_fastArray.length] = _value;
        _fastArray.indexMap[_value] = _fastArray.length;
        _fastArray.length += 1;
    }

    function remove(Data storage _fastArray, uint256 _value) internal {
        uint256 index = _fastArray.indexMap[_value];
        _fastArray.array[index] = _fastArray.array[_fastArray.length - 1];
        delete _fastArray.indexMap[_value];
        _fastArray.length -= 1;
    }

    function get(Data storage _fastArray, uint256 _index)
        public
        view
        returns (uint256)
    {
        return _fastArray.array[_index];
    }

    function length(Data storage _fastArray) public view returns (uint256) {
        return _fastArray.length;
    }

    function contains(Data storage _fastArray, uint256 _value)
        public
        view
        returns (bool)
    {
        return _fastArray.indexMap[_value] != 0;
    }
}
