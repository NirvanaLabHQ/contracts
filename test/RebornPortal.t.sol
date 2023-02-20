// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import "forge-std/Test.sol";
import {DeployProxy} from "foundry-upgrades/utils/DeployProxy.sol";

import "src/RebornPortal.sol";
import {RBT} from "src/RBT.sol";
import {RewardVault} from "src/RewardVault.sol";
import {IRebornDefination} from "src/interfaces/IRebornPortal.sol";
import {EventDefination} from "src/test/EventDefination.sol";
import {TestUtils} from "test/TestUtils.sol";
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
        rbt = TestUtils.deployRBT(owner);
        mintRBT(rbt, owner, _user, 100000 ether);

        // deploy portal
        portal = deployPortal();
        vm.prank(owner);
        address[] memory toAdd = new address[](1);
        toAdd[0] = signer;
        address[] memory toRemove;
        portal.updateSigners(toAdd, toRemove);

        // deploy vault
        RewardVault vault = new RewardVault(address(portal), address(rbt));
        vm.prank(owner);
        portal.setVault(vault);

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
        emit Incarnate(_user, 5 ether, 20 ether);
        emit Transfer(_user, address(0), 25 ether);

        hoax(_user);
        // rbt.permit(_user, address(portal), MAX_INT, deadline, v, r, s);
        bytes memory callData = abi.encodeWithSignature(
            "incarnate((uint256,uint256),address,uint256,uint256,bytes32,bytes32,uint8)",
            5 ether,
            20 ether,
            address(0),
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
        mintRBT(rbt, owner, address(portal.vault()), reward);

        testIncarnateWithPermit();
        vm.expectEmit(true, true, true, true);
        emit Engrave(seed, _user, 1, score, reward);

        vm.prank(signer);
        portal.engrave(seed, _user, reward, score, age, 1);

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

    function testBaptise(address user, uint256 amount) public {
        vm.assume(user != address(0));
        vm.assume(amount < rbt.cap() - rbt.totalSupply());
        mintRBT(rbt, owner, address(portal.vault()), amount);

        vm.expectEmit(true, true, true, true);
        emit Baptise(user, amount);
        emit Transfer(address(0), user, amount);

        vm.prank(signer);
        portal.baptise(user, amount);

        // expect baptise to the same address fail
        vm.expectRevert(AlreadyBaptised.selector);

        vm.prank(signer);
        portal.baptise(user, amount);
    }
}
