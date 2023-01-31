// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.17;

interface IRebornDefination {
    enum TALANT {
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
        TALANT talent;
        PROPERTIES properties;
    }

    event Incarnate(
        uint256 indexed talentPoint,
        uint256 indexed PropertyPoint,
        TALANT talent,
        PROPERTIES properties
    );

    event NewSoupPrice(uint256 price);

    event NewPricePoint(uint256 price);
}

interface IRebornPortal is IRebornDefination {
    /** init enter and buy */
    function incarnate(Innate memory innate) external payable;

    /** init enter and buy with permit signature */
    function incarnate(
        Innate memory innate,
        uint256 amount,
        uint256 deadline,
        bytes32 r,
        bytes32 s,
        uint8 v
    ) external payable;

    /** save data on chain and get reward */
    function engrave() external;

    /** set soup price */
    function setSoupPrice(uint256 price) external;

    /** set price and point */
    function setPriceAndPoint(uint256 price) external;
}
