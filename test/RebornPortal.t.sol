// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import "forge-std/Test.sol";
import {DeployProxy} from "foundry-upgrades/utils/DeployProxy.sol";

import "src/RebornPortal.sol";
import {RBT} from "src/RBT.sol";
import {IRebornDefination} from "src/interfaces/IRebornPortal.sol";

import {ECDSAUpgradeable} from "@openzeppelin/contracts-upgradeable/utils/cryptography/ECDSAUpgradeable.sol";

contract TokenTest is Test, IRebornDefination {
    RebornPortal portal;
    RBT rbt;
    address owner = vm.addr(2);
    address user = vm.addr(10);
    address signer = vm.addr(11);
    // solhint-disable-next-line var-name-mixedcase
    bytes32 private constant _PERMIT_TYPEHASH =
        keccak256(
            "Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)"
        );
    bytes32 _TYPE_HASH =
        keccak256(
            "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
        );

    function setUp() public {
        rbt = deployRBT();
        mintRBT(rbt, owner, user, 100 ether);

        // deploy portal
        portal = deployPortal();
        vm.prank(owner);
        address[] memory toAdd = new address[](1);
        toAdd[0] = signer;
        address[] memory toRemove;
        portal.updateSigners(toAdd, toRemove);
    }

    function deployPortal() public returns (RebornPortal portal) {
        portal = new RebornPortal();
        portal.initialize(
            rbt,
            0.1 * 1 ether,
            0x00000000004020000000000000504030000000604020100000000231e19140f,
            owner,
            "Degen Tombstone",
            "RIP"
        );
    }

    function deployRBT() public returns (RBT token) {
        token = new RBT();
        token.initialize("REBORN", "RBT", 10**10 * 1 ether, owner);
    }

    function mintRBT(
        RBT rbt,
        address owner,
        address account,
        uint256 amount
    ) public {
        vm.prank(owner);
        rbt.mint(account, amount);
    }

    function testTalantPrice() public {
        assertEq(portal.talentPrice(TALANT.Degen), 0);
        assertEq(portal.talentPrice(TALANT.Gifted), 2 ether);
        assertEq(portal.talentPrice(TALANT.Genius), 4 ether);
    }

    function testTalantPoint() public {
        assertEq(portal.talentPoint(TALANT.Degen), 3);
        assertEq(portal.talentPoint(TALANT.Gifted), 4);
        assertEq(portal.talentPoint(TALANT.Genius), 5);
    }

    function testPropertiesPrice() public {
        assertEq(portal.propertyPrice(PROPERTIES.BASIC), 0);
        assertEq(portal.propertyPrice(PROPERTIES.C), 1 ether);
        assertEq(portal.propertyPrice(PROPERTIES.B), 2 ether);
        assertEq(portal.propertyPrice(PROPERTIES.A), 4 ether);
        assertEq(portal.propertyPrice(PROPERTIES.S), 6 ether);
    }

    function testPropertiesPoint() public {
        assertEq(portal.propertyPoint(PROPERTIES.BASIC), 15);
        assertEq(portal.propertyPoint(PROPERTIES.C), 20);
        assertEq(portal.propertyPoint(PROPERTIES.B), 25);
        assertEq(portal.propertyPoint(PROPERTIES.A), 30);
        assertEq(portal.propertyPoint(PROPERTIES.S), 35);
    }

    /**
     * @dev core process of incarnate
     */
    function testIncarnateWithPermit() public {
        uint256 MAX_INT = 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff;
        uint256 deadline = block.timestamp + 100;
        bytes32 structHash = keccak256(
            abi.encode(
                _PERMIT_TYPEHASH,
                user,
                address(portal),
                MAX_INT,
                0,
                deadline
            )
        );

        bytes32 domainSeparator = keccak256(
            abi.encode(
                _TYPE_HASH,
                keccak256(abi.encodePacked(rbt.name())),
                keccak256("1"),
                block.chainid,
                address(rbt)
            )
        );

        bytes32 hash = ECDSAUpgradeable.toTypedDataHash(
            domainSeparator,
            structHash
        );

        // sign
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(10, hash);

        vm.expectEmit(true, true, true, true);
        emit Incarnate(
            user,
            5,
            35,
            IRebornDefination.TALANT.Genius,
            IRebornDefination.PROPERTIES.S,
            10 ether
        );

        hoax(user);
        // rbt.permit(user, address(portal), MAX_INT, deadline, v, r, s);
        bytes memory callData = abi.encodeWithSignature(
            "incarnate((uint8,uint8),uint256,uint256,bytes32,bytes32,uint8)",
            Innate(
                IRebornDefination.TALANT.Genius,
                IRebornDefination.PROPERTIES.S
            ),
            MAX_INT,
            deadline,
            r,
            s,
            v
        );
        payable(address(portal)).call{value: 0.1 * 1 ether}(callData);
    }

    function testEngrave(
        bytes32 seed,
        uint208 reward,
        uint16 score,
        uint16 age
    ) public {
        vm.assume(reward < rbt.cap() - 100 ether);
        mintRBT(rbt, owner, address(portal), reward);

        uint16 l = uint16(portal.findLocation(score));

        vm.expectEmit(true, true, true, true);
        emit Engrave(seed, user, score, reward);

        vm.prank(signer);
        portal.engrave(seed, user, reward, score, age, l);

        // assertEq(portal.details[], b);
    }
}
