// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

// A simple array that supports insert and removal.
// The values are assumed to be unique and the library is meant to be lightweight.
// So when calling insert or remove, the caller is responsible to know whether a value already exists in the array or not.
library FastArray {
    struct Data {
        mapping(uint256 => uint256) array;
        mapping(uint256 => uint256) indexMap;
        uint256 length;
    }

    modifier checkEmpty(Data storage _fastArray) {
        require(_fastArray.length > 0, "can not remove from empty array");
        _;
    }

    function insert(Data storage _fastArray, uint256 _value) internal {
        _fastArray.array[_fastArray.length] = _value;
        _fastArray.indexMap[_value] = _fastArray.length;
        _fastArray.length += 1;
    }

    /**
     * @dev remove item from array,but not keep sort
     */
    function remove(
        Data storage _fastArray,
        uint256 _value
    ) internal checkEmpty(_fastArray) {
        uint256 index = _fastArray.indexMap[_value];

        _checkItemExist(_fastArray, _value, index);
        _checkOutOfBounds(index, _fastArray.length);

        _fastArray.array[index] = _fastArray.array[_fastArray.length - 1];
        delete _fastArray.indexMap[_value];
        delete _fastArray.array[_fastArray.length - 1];

        _fastArray.length -= 1;
    }

    function removeKeepSort(
        Data storage _fastArray,
        uint256 _value
    ) internal checkEmpty(_fastArray) {
        uint256 index = _fastArray.indexMap[_value];

        _checkItemExist(_fastArray, _value, index);
        _checkOutOfBounds(index, _fastArray.length);

        uint256 tempLastItem = _fastArray.array[_fastArray.length - 1];

        for (uint256 i = index; i < _fastArray.length - 1; i++) {
            _fastArray.indexMap[_fastArray.array[i + 1]] = i;
            _fastArray.array[i] = _fastArray.array[i + 1];
        }

        delete _fastArray.indexMap[tempLastItem];
        delete _fastArray.array[_fastArray.length - 1];
        _fastArray.length -= 1;
    }

    function get(
        Data storage _fastArray,
        uint256 _index
    ) public view returns (uint256) {
        _checkOutOfBounds(_index, _fastArray.length);
        return _fastArray.array[_index];
    }

    function length(Data storage _fastArray) public view returns (uint256) {
        return _fastArray.length;
    }

    function contains(
        Data storage _fastArray,
        uint256 _value
    ) public view returns (bool) {
        return _fastArray.indexMap[_value] != 0;
    }

    /** internal check */
    function _checkItemExist(
        Data storage _fastArray,
        uint256 _value,
        uint256 index
    ) internal view {
        if (index == 0 && _value != _fastArray.array[0]) {
            revert("remove value not exist");
        }
    }

    function _checkOutOfBounds(uint256 index, uint256 len) internal pure {
        if (index >= len) {
            revert("out of bounds");
        }
    }
}
