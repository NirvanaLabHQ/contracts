// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import "forge-std/Test.sol";
import "src/RebornPortal.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

contract InfuseHandler is Test {
    using EnumerableSet for EnumerableSet.UintSet;
    using EnumerableSet for EnumerableSet.AddressSet;
    RebornPortal internal _portal;
    RBT internal _rbt;

    address[] public actors;

    address internal currentActor;

    // user => tokenIds
    mapping(address => EnumerableSet.UintSet) internal _stakedPool;

    // tokenId => users
    mapping(uint256 => EnumerableSet.AddressSet) internal _poolUsers;

    EnumerableSet.UintSet internal _wholeStakedPool;

    modifier useActor(uint256 actorIndexSeed) {
        currentActor = actors[bound(actorIndexSeed, 0, actors.length - 1)];
        vm.startPrank(currentActor);
        deal(address(_rbt), currentActor, UINT256_MAX);
        _;
        vm.stopPrank();
    }

    function _initActors(uint256 amount) internal {
        for (uint256 i = 0; i < amount; i++) {
            actors.push(address(uint160(uint256(keccak256(abi.encode(i))))));
        }
    }

    constructor(RebornPortal portal_, RBT rbt_) {
        _portal = portal_;
        _rbt = rbt_;
        _initActors(50);
    }

    function handleInfuse(
        uint256 tokenId,
        uint256 amountSeed,
        uint256 actorIndexSeed
    ) external useActor(actorIndexSeed) {
        deal(address(_rbt), currentActor, UINT256_MAX);

        uint256 amount = bound(amountSeed, 0, 1 << 128);

        _rbt.approve(address(_portal), amount);
        _portal.infuse(tokenId, amount);

        EnumerableSet.UintSet storage stakedPoolArray = _stakedPool[
            currentActor
        ];
        EnumerableSet.AddressSet storage toPoolUsers = _poolUsers[tokenId];

        // insert to stakedPoolArray
        stakedPoolArray.add(tokenId);
        _wholeStakedPool.add(tokenId);
        toPoolUsers.add(currentActor);
    }

    function handleSwitchPool(
        uint256 fromTokenId,
        uint256 toTokenId,
        uint256 actorIndexSeed
    ) external useActor(actorIndexSeed) {
        EnumerableSet.UintSet storage stakedPoolArray = _stakedPool[
            currentActor
        ];
        EnumerableSet.AddressSet storage toPoolUsers = _poolUsers[toTokenId];

        // bound amount to bound revert
        uint256 amount = bound(
            fromTokenId,
            0,
            _portal.getPortfolio(currentActor, fromTokenId).accumulativeAmount
        );

        _portal.switchPool(fromTokenId, toTokenId, amount);

        // if the resume is zero, remove it
        if (
            _portal
                .getPortfolio(currentActor, fromTokenId)
                .accumulativeAmount == 0
        ) {
            stakedPoolArray.remove(fromTokenId);
        }

        // insert tokenId to stakedPoolArray
        stakedPoolArray.add(toTokenId);
        _wholeStakedPool.add(toTokenId);
        toPoolUsers.add(currentActor);
    }

    function getWholeStakedPools()
        public
        view
        returns (uint256[] memory array)
    {
        return _wholeStakedPool.values();
    }

    function getWhoStakedPools(
        address user
    ) public view returns (uint256[] memory array) {
        return _stakedPool[user].values();
    }

    function getPoolUsers(
        uint256 tokenId
    ) public view returns (address[] memory) {
        return _poolUsers[tokenId].values();
    }
}
