// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.17;

interface IRebornDefination {
    struct Innate {
        uint256 talentPrice;
        uint256 propertyPrice;
    }

    struct LifeDetail {
        bytes32 seed;
        address creator;
        uint16 age;
        uint32 round;
        uint48 nothing;
        uint128 cost;
        uint128 reward;
        uint256 score;
    }

    struct Pool {
        uint256 totalAmount;
    }

    struct Portfolio {
        uint256 accumulativeAmount;
    }

    event Incarnate(
        address indexed user,
        uint256 indexed talentPrice,
        uint256 indexed PropertyPrice
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

    event SignerUpdate(address signer, bool valid);

    event Refer(address referee, address referrer);

    event DecreaseFromPool(
        address indexed account,
        uint256 tokenId,
        uint256 amount
    );

    event IncreaseToPool(
        address indexed account,
        uint256 tokenId,
        uint256 amount
    );

    /// @dev revert when msg.value is insufficient
    error InsufficientAmount();
    /// @dev revert when to caller is not signer
    error NotSigner();

    /// @dev revert when the random seed is duplicated
    error SameSeed();
    /// @dev revert when swith amount from pool exceed staked balance
    error SwitchAmountExceedBalance();
}

interface IRebornPortal is IRebornDefination {
    /**
     * @dev user buy the innate for the life
     * @param innate talent and property choice
     * @param referrer the referrer address
     */
    function incarnate(Innate memory innate, address referrer) external payable;

    /**
     * @dev engrave the result on chain and reward
     * @param seed random seed in bytes32
     * @param user user address
     * @param reward $REBORN user earns, decimal 10^18
     * @param score life score
     * @param cost user cost for this life
     */
    function engrave(
        bytes32 seed,
        address user,
        uint256 reward,
        uint256 score,
        uint256 age,
        uint256 cost
    ) external;

    /**
     * @dev reward for share the game
     * @param user user address
     * @param amount amount for reward
     */
    function baptise(address user, uint256 amount) external;

    /**
     * @dev stake $REBORN on this tombstone
     * @param tokenId tokenId of the life to stake
     * @param amount stake amount, decimal 10^18
     */
    function infuse(uint256 tokenId, uint256 amount) external;

    /**
     * @dev stake $REBORN with permit
     * @param tokenId tokenId of the life to stake
     * @param amount amount of $REBORN to stake
     * @param r r of signature
     * @param s v of signature
     * @param v v of signature
     */
    function infuse(
        uint256 tokenId,
        uint256 amount,
        uint256 deadline,
        bytes32 r,
        bytes32 s,
        uint8 v
    ) external;

    /**
     * @dev switch stake amount from poolFrom to poolTo
     * @param fromTokenId tokenId of from pool
     * @param toTokenId tokenId of to pool
     * @param amount amount to switch
     */
    function switchPool(
        uint256 fromTokenId,
        uint256 toTokenId,
        uint256 amount
    ) external;

    /**
     * @dev a bottle of soup is needed to play the game, only owner can set the price
     * @param price the price of soup, decimal 10^18
     */
    function setSoupPrice(uint256 price) external;
}
