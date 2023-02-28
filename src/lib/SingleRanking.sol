// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "forge-std/console.sol";

import "./FastArray.sol";
import "./RankingRedBlackTree.sol";

library SingleRanking {
    using FastArray for FastArray.Data;
    using RankingRedBlackTree for RankingRedBlackTree.Tree;

    struct Data {
        RankingRedBlackTree.Tree tree;
        mapping(uint => FastArray.Data) keys;
        uint length;
    }

    function add(Data storage _singleRanking, uint _key, uint _value) internal {
        FastArray.Data storage keys = _singleRanking.keys[_value];

        if (FastArray.length(keys) == 0) {
            _singleRanking.tree.insert(_value);
        } else {
            _singleRanking.tree.addToCount(_value, 1);
        }

        _singleRanking.keys[_value].insert(_key);

        _singleRanking.length += 1;

        // if (FastArray.length(keys) == 0) {
        //     _singleRanking.length += 1;
        // } else {
        //     // remove old key to keep only one value for one key
        //     uint256 oldKey = keys.get(0);
        //     _singleRanking.tree.removeWithKey(oldKey);
        //     _singleRanking.keys[_value].remove(oldKey);
        // }

        // _singleRanking.tree.insert(_value);

        // _singleRanking.keys[_value].insert(_key);
    }

    function remove(
        Data storage _singleRanking,
        uint _key,
        uint _value
    ) internal {
        FastArray.Data storage keys = _singleRanking.keys[_value];

        if (FastArray.length(keys) > 0) {
            keys.remove(_key);

            if (FastArray.length(keys) == 0) {
                _singleRanking.tree.remove(_value);
            } else {
                _singleRanking.tree.minusFromCount(_value, 1);
            }
        }

        _singleRanking.length -= 1;
    }

    function length(Data storage _singleRanking) public view returns (uint) {
        return _singleRanking.length;
    }

    function get(
        Data storage _singleRanking,
        uint _offset,
        uint _count
    ) public view returns (uint[] memory) {
        require(_offset >= 0, "Offet can not be negative");
        require(
            _count >= 0 && _count <= 100,
            "Count must be between 0 and 100"
        );

        uint[] memory result = new uint[](_count);
        uint size = 0;
        uint id;
        (id, _offset) = _singleRanking.tree.lastByOffset(_offset);

        while (id != 0) {
            uint value = _singleRanking.tree.value(id);
            FastArray.Data storage keys = _singleRanking.keys[value];

            if (_offset >= FastArray.length(keys)) {
                _offset -= FastArray.length(keys);
            } else if (FastArray.length(keys) < _offset + _count) {
                uint index = FastArray.length(keys) - 1;

                while (index >= _offset) {
                    uint key = keys.get(index);

                    result[size] = key;
                    size += 1;

                    if (index == 0) {
                        break;
                    }

                    index -= 1;
                }

                _count -= FastArray.length(keys) - _offset;
                _offset = 0;
            } else {
                uint index = _count - 1;

                while (index >= _offset) {
                    uint key = keys.get(index);

                    result[size] = key;
                    size += 1;

                    if (index == 0) {
                        break;
                    }

                    index -= 1;
                }
                // result[size] = value;
                break;
            }

            id = _singleRanking.tree.prev(id);
        }

        return result;
    }
}
