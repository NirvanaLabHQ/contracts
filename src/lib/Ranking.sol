// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.17;

import "./SingleRanking.sol";

library Ranking {
    struct Data {
        mapping(uint256 => SingleRanking.Data) rankings;
    }

    function add(
        Data storage _rankings,
        uint256 _category,
        uint256 _key,
        uint256 _value
    ) internal {
        SingleRanking.add(_rankings.rankings[_category], _key, _value);
    }

    function remove(
        Data storage _rankings,
        uint256 _category,
        uint256 _key,
        uint256 _value
    ) internal {
        SingleRanking.remove(_rankings.rankings[_category], _key, _value);
    }

    function length(Data storage _rankings, uint256 _category)
        public
        view
        returns (uint256)
    {
        return SingleRanking.length(_rankings.rankings[_category]);
    }

    function get(
        Data storage _rankings,
        uint256 _category,
        uint256 _offset,
        uint256 _count
    ) public view returns (uint256[] memory) {
        return
            SingleRanking.get(_rankings.rankings[_category], _offset, _count);
    }
}
