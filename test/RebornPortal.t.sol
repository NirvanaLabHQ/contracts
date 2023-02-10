// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import "forge-std/Test.sol";
import {DeployProxy} from "foundry-upgrades/utils/DeployProxy.sol";

import "src/RebornPortal.sol";
import {RBT} from "src/RBT.sol";
import {IRebornDefination} from "src/interfaces/IRebornPortal.sol";
import {EventDefination} from "src/test/EventDefination.sol";
import {Utils} from "test/Utils.sol";
import {ECDSAUpgradeable} from "@openzeppelin/contracts-upgradeable/utils/cryptography/ECDSAUpgradeable.sol";

contract RebornPortalTest is Test, IRebornDefination, EventDefination {
    RebornPortal portal;
    RBT rbt;
    address owner = vm.addr(2);
    address _user = vm.addr(10);
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
        rbt = Utils.deployRBT(owner);
        mintRBT(rbt, owner, _user, 100 ether);

        // deploy portal
        portal = deployPortal();
        vm.prank(owner);
        address[] memory toAdd = new address[](1);
        toAdd[0] = signer;
        address[] memory toRemove;
        portal.updateSigners(toAdd, toRemove);

        // add portal as minter
        vm.prank(owner);
        address[] memory minterToAdd = new address[](1);
        minterToAdd[0] = address(portal);
        address[] memory minterToRemove;
        rbt.updateMinter(minterToAdd, minterToRemove);
    }

    function deployPortal() public returns (RebornPortal portal_) {
        portal_ = new RebornPortal();
        portal_.initialize(
            rbt,
            0.01 * 1 ether,
            0x00000000004020000000000000504030000000604020100000000231e19140f,
            owner,
            "Degen Tombstone",
            "RIP"
        );
    }

    function mintRBT(
        RBT rbt_,
        address owner_,
        address account,
        uint256 amount
    ) public {
        vm.prank(owner_);
        rbt_.mint(account, amount);
    }

    function testTalantPrice() public {
        assertEq(portal.talentPrice(TALENT.Degen), 0);
        assertEq(portal.talentPrice(TALENT.Gifted), 2 ether);
        assertEq(portal.talentPrice(TALENT.Genius), 4 ether);
    }

    function testTalantPoint() public {
        assertEq(portal.talentPoint(TALENT.Degen), 3);
        assertEq(portal.talentPoint(TALENT.Gifted), 4);
        assertEq(portal.talentPoint(TALENT.Genius), 5);
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
     * @dev process of incarnate
     */
    function testIncarnateWithPermit() public {
        uint256 MAX_INT = 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff;
        uint256 deadline = block.timestamp + 100;
        bytes32 structHash = keccak256(
            abi.encode(
                _PERMIT_TYPEHASH,
                _user,
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
            _user,
            5,
            35,
            IRebornDefination.TALENT.Genius,
            IRebornDefination.PROPERTIES.S,
            10 ether,
            1
        );

        hoax(_user);
        // rbt.permit(_user, address(portal), MAX_INT, deadline, v, r, s);
        bytes memory callData = abi.encodeWithSignature(
            "incarnate((uint8,uint8),uint256,uint256,bytes32,bytes32,uint8)",
            Innate(
                IRebornDefination.TALENT.Genius,
                IRebornDefination.PROPERTIES.S
            ),
            MAX_INT,
            deadline,
            r,
            s,
            v
        );
        payable(address(portal)).call{value: 0.01 * 1 ether}(callData);
    }

    function testEngrave(
        bytes32 seed,
        uint256 reward,
        uint256 score,
        uint256 age
    ) public {
        vm.assume(reward < rbt.cap() - 100 ether);

        testIncarnateWithPermit();
        vm.expectEmit(true, true, true, true);
        emit Engrave(seed, _user, score, reward);

        vm.prank(signer);
        portal.engrave(seed, _user, reward, score, age, 1);

        // assertEq(portal.details[], b);
    }

    function testEngraveSameTokenIdFail(
        bytes32 seed,
        uint256 reward,
        uint256 score,
        uint256 age
    ) public {
        vm.assume(reward < rbt.cap() - 100 ether);

        testIncarnateWithPermit();

        vm.startPrank(signer);
        portal.engrave(seed, _user, reward, score, age, 1);

        vm.expectRevert(AlreadEngraved.selector);
        portal.engrave(seed, _user, reward, score, age, 1);
        vm.stopPrank();
        // assertEq(portal.details[], b);
    }

    function testEngraveNonexistTokenIdFail(
        bytes32 seed,
        uint256 reward,
        uint256 score,
        uint256 age
    ) public {
        vm.assume(reward < rbt.cap() - 100 ether);

        vm.startPrank(signer);

        vm.expectRevert(bytes("ERC721: invalid token ID"));
        portal.engrave(seed, _user, reward, score, age, 1);
        vm.stopPrank();
        // assertEq(portal.details[], b);
    }

    function testInfuseNumericalValue(uint256 amount) public {
        vm.assume(amount < rbt.cap() - 100 ether);
        testEngrave(bytes32(new bytes(32)), 10, 10, 10);

        mintRBT(rbt, owner, _user, amount);

        vm.expectEmit(true, true, true, true);
        emit Infuse(_user, 1, amount);
        emit Transfer(_user, address(portal), amount);

        mockInfuse(_user, 1, amount);

        assertEq(portal.pools(1), amount);
        assertEq(portal.portfolios(_user, 1), amount);
    }

    function mockInfuse(
        address user,
        uint256 tokenId,
        uint256 amount
    ) public {
        vm.startPrank(user);
        rbt.approve(address(portal), amount);
        portal.infuse(tokenId, amount);
        vm.stopPrank();
    }

    function testDryNumericalValue(uint256 amount) public {
        vm.assume(amount < rbt.cap() - 100 ether);

        testEngrave(bytes32(new bytes(32)), amount, 10, 10);
        mockInfuse(_user, 1, amount);

        console.log(rbt.balanceOf(address(portal)));
        vm.expectEmit(true, true, true, true);
        emit Dry(_user, 1, amount);
        emit Transfer(address(portal), _user, amount);

        vm.prank(_user);
        portal.dry(1, amount);
    }

    function testTokenUri(
        bytes32 seed,
        uint208 reward,
        uint16 score,
        uint16 age
    ) public {
        testEngrave(seed, reward, score, age);
        string memory metadata = portal.tokenURI(1);
        // console.log(metadata);
    }
}
