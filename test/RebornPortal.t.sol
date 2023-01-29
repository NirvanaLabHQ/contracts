// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import {DeployProxy} from "foundry-upgrades/utils/DeployProxy.sol";

import "src/RebornPortal.sol";
import {RBT} from "src/RBT.sol";
import {IRebornDefination} from "src/interfaces/IRebornPortal.sol";

contract TokenTest is Test, IRebornDefination {
    RebornPortal portal;
    RBT rbt;
    DeployProxy internal _deployProxy;
    address owner = address(2);

    function setUp() public {
        portal = new RebornPortal();
        _deployProxy = new DeployProxy();
        RebornPortal portalImpl = new RebornPortal();
        rbt = deployRBT();
        bytes memory initData = abi.encodeWithSelector(
            RebornPortal.initialize.selector,
            address(rbt),
            0.1 * 1 ether,
            0x00000000000004200000000000064210,
            owner
        );
        portal = RebornPortal(
            _deployProxy.deployErc1967Proxy(address(portalImpl), initData)
        );
    }

    function deployRBT() public returns (RBT token) {
        RBT tokenImpl = new RBT();
        bytes memory initData = abi.encodeWithSelector(
            RBT.initialize.selector,
            "REBORN",
            "RBT",
            10**10 * 1 ether,
            owner
        );
        token = RBT(
            _deployProxy.deployErc1967Proxy(address(tokenImpl), initData)
        );
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
