// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.17;

import "./FastArray.sol";
import "./RankingRedBlackTree.sol";

library SingleRanking {
    struct Data {
        RankingRedBlackTree.Tree tree;
        mapping(uint256 => FastArray.Data) keys;
        uint256 length;
    }

    function add(
        Data storage _singleRanking,
        uint256 _key,
        uint256 _value
    ) internal {
        FastArray.Data storage keys = _singleRanking.keys[_value];

        if (FastArray.length(keys) == 0) {
            RankingRedBlackTree.insert(_singleRanking.tree, _value);
        } else {
            RankingRedBlackTree.addToCount(_singleRanking.tree, _value, 1);
        }

        FastArray.insert(_singleRanking.keys[_value], _key);

        _singleRanking.length += 1;
    }

    function remove(
        Data storage _singleRanking,
        uint256 _key,
        uint256 _value
    ) internal {
        FastArray.Data storage keys = _singleRanking.keys[_value];

        if (FastArray.length(keys) > 0) {
            FastArray.remove(keys, _key);

            if (FastArray.length(keys) == 0) {
                RankingRedBlackTree.remove(_singleRanking.tree, _value);
            } else {
                RankingRedBlackTree.minusFromCount(
                    _singleRanking.tree,
                    _value,
                    1
                );
            }
        }

        _singleRanking.length -= 1;
    }

    function length(Data storage _singleRanking) public view returns (uint256) {
        return _singleRanking.length;
    }

    function get(
        Data storage _singleRanking,
        uint256 _offset,
        uint256 _count
    ) public view returns (uint256[] memory) {
        require(_offset >= 0, "Offet can not be negative");
        require(_count >= 0 && _count <= 40, "Count must be between 0 and 40");

        uint256[] memory result = new uint256[](_count);
        uint256 size = 0;
        uint256 id;
        (id, _offset) = RankingRedBlackTree.lastByOffset(
            _singleRanking.tree,
            _offset
        );

        while (id != 0) {
            uint256 value = RankingRedBlackTree.value(_singleRanking.tree, id);
            FastArray.Data storage keys = _singleRanking.keys[value];

            if (_offset >= FastArray.length(keys)) {
                _offset -= FastArray.length(keys);
            } else if (FastArray.length(keys) < _offset + _count) {
                uint256 index = FastArray.length(keys) - 1;

                while (index >= _offset) {
                    uint256 key = FastArray.get(keys, index);

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
                uint256 index = _count - 1;

                while (index >= _offset) {
                    uint256 key = FastArray.get(keys, index);

                    result[size] = key;
                    size += 1;

                    if (index == 0) {
                        break;
                    }

                    index -= 1;
                }
                result[size] = value;
                break;
            }

            id = RankingRedBlackTree.prev(_singleRanking.tree, id);
        }

        return result;
    }
}
