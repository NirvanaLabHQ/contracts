// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";

import "src/RebornPortal.sol";
import {IRebornDefination} from "src/interfaces/IRebornPortal.sol";

contract TokenTest is Test, IRebornDefination {
    RebornPortal portal;

    function setUp() public {
        portal = new RebornPortal();
    }

    function testTalantPrice() public {
        assertEq(portal.talentPrice(TALANT.Degen), 0);
        assertEq(portal.talentPrice(TALANT.Gifted), 2 ether);
        assertEq(portal.talentPrice(TALANT.Genius), 4 ether);
    }

    function testPropertiesPrice() public {
        assertEq(portal.propertiesPrice(PROPERTIES.BASIC), 0);
        assertEq(portal.propertiesPrice(PROPERTIES.C), 1 ether);
        assertEq(portal.propertiesPrice(PROPERTIES.B), 2 ether);
        assertEq(portal.propertiesPrice(PROPERTIES.A), 4 ether);
        assertEq(portal.propertiesPrice(PROPERTIES.S), 6 ether);
    }
}
