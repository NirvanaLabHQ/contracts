// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.17;

interface IRebornDefination {
    struct Innate {
        uint256 talent;
        uint256 properties;
    }

    struct LifeDetail {
        bytes32 seed;
        address creator;
        uint16 age;
        uint32 round;
        uint48 nothing;
        uint128 cost;
        uint128 reward;
    }

    struct Pool {
        uint256 totalAmount;
    }

    struct Portfolio {
        uint256 accumulativeAmount;
    }

    event Incarnate(
        address indexed user,
        uint256 indexed talentPoint,
        uint256 indexed PropertyPoint,
        uint256 indulgences
    );

    event Engrave(
        bytes32 indexed seed,
        address indexed user,
        uint256 indexed tokenId,
        uint256 score,
        uint256 reward
    );

    event ReferReward(address indexed user, uint256 amount);

    event Infuse(address indexed user, uint256 indexed tokenId, uint256 amount);

    event Dry(address indexed user, uint256 indexed tokenId, uint256 amount);

    event Baptise(address indexed user, uint256 amount);

    event NewSoupPrice(uint256 price);

    event NewTalentPrice(uint256 price);

    event SignerUpdate(address signer, bool valid);

    event Refer(address referee, address referrer);

    error InsufficientAmount();
    error NotSigner();
    error AlreadyEngraved();
    error AlreadyBaptised();
    error TalentOutOfScope();
    error PropertyOutOfScope();
    error SameSeed();
}

interface IRebornPortal is IRebornDefination {
    /** init enter and buy */
    function incarnate(Innate memory innate, address referrer) external payable;

    function incarnate(
        Innate memory innate,
        address referrer,
        uint256 amount,
        uint256 deadline,
        bytes32 r,
        bytes32 s,
        uint8 v
    ) external payable;

    /** save data on chain and get reward */
    function engrave(
        bytes32 seed,
        address user,
        uint256 reward,
        uint256 score,
        uint256 age,
        uint256 locate
    ) external;

    /** @dev reward $REBORN for sharing. One address once. */
    function baptise(address user, uint256 amount) external;

    /// @dev stake $REBORN on this tombstone
    function infuse(uint256 tokenId, uint256 amount) external;

    /// @dev unstake $REBORN on this tombstone
    function dry(uint256 tokenId, uint256 amount) external;

    /** set soup price */
    function setSoupPrice(uint256 price) external;

    /** set price and point */
    function setTalentPrice(uint256 price) external;
}
