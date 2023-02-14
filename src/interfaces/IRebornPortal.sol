// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.17;

interface IRebornDefination {
    enum TALENT {
        Degen,
        Gifted,
        Genius
    }

    enum PROPERTIES {
        BASIC,
        C,
        B,
        A,
        S
    }

    struct Innate {
        TALENT talent;
        PROPERTIES properties;
    }

    struct LifeDetail {
        bytes32 seed;
        address creator;
        uint16 age;
        uint16 round;
        uint64 nothing;
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
        TALENT talent,
        PROPERTIES properties,
        uint256 indulgences
    );

    event Engrave(
        bytes32 indexed seed,
        address indexed user,
        uint256 indexed tokenId,
        uint256 score,
        uint256 reward
    );

    event Infuse(address indexed user, uint256 indexed tokenId, uint256 amount);

    event Dry(address indexed user, uint256 indexed tokenId, uint256 amount);

    event Baptise(address indexed user, uint256 amount);

    event NewSoupPrice(uint256 price);

    event NewPricePoint(uint256 price);

    event SignerUpdate(address signer, bool valid);

    event Refer(address referee, address referrer);

    error InsufficientAmount();
    error NotSigner();
    error AlreadyEngraved();
    error AlreadyBaptised();
}

interface IRebornPortal is IRebornDefination {
    /** init enter and buy */
    function incarnate(Innate memory innate) external payable;

    /** init enter and buy */
    function incarnate(Innate memory innate, address referrer) external payable;

    /** init enter and buy with permit signature */
    function incarnate(
        Innate memory innate,
        uint256 amount,
        uint256 deadline,
        bytes32 r,
        bytes32 s,
        uint8 v
    ) external payable;

    function incarnate(
        Innate memory innate,
        uint256 amount,
        uint256 deadline,
        address referrer,
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
    function setPriceAndPoint(uint256 price) external;
}
