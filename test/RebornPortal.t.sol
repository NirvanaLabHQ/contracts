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
import {IERC20Upgradeable} from "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import {BurnPool} from "src/BurnPool.sol";
import {VRFCoordinatorV2Mock} from "src/mock/VRFCoordinatorV2Mock.sol";

contract RebornPortalTest is Test, IRebornDefination, EventDefination {
    uint256 public constant SOUP_PRICE = 0.01 * 1 ether;
    RebornPortal portal;
    RBT rbt;
    BurnPool burnPool;
    address owner = vm.addr(2);
    address _user = vm.addr(10);
    address signer = vm.addr(11);
    uint256 internal _seedIndex;
    // address on bnb testnet
    address internal _vrfCoordinator;
    // solhint-disable-next-line var-name-mixedcase
    bytes32 internal constant _PERMIT_TYPEHASH =
        keccak256(
            "Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)"
        );
    bytes32 _TYPE_HASH =
        keccak256(
            "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
        );

    function setUp() public virtual {
        // ignore effect of chainId to tokenId
        vm.chainId(0);

        rbt = TestUtils.deployRBT(owner);
        mintRBT(rbt, owner, _user, 100000 ether);

        // deploy vrf coordinator
        _vrfCoordinator = address(new VRFCoordinatorV2Mock());

        // deploy portal
        portal = deployPortal();
        vm.prank(owner);
        address[] memory toAdd = new address[](1);
        toAdd[0] = signer;
        address[] memory toRemove;
        portal.updateSigners(toAdd, toRemove);

        // deploy burn pool
        burnPool = new BurnPool(address(portal), address(rbt));
        vm.prank(owner);
        portal.setBurnPool(address(burnPool));

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
            owner,
            "Degen Tombstone",
            "RIP",
            _vrfCoordinator
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

    function permitRBT(
        address spender
    )
        public
        view
        returns (
            uint256 permitAmount,
            uint256 deadline,
            bytes32 r,
            bytes32 s,
            uint8 v
        )
    {
        permitAmount = 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff;
        deadline = block.timestamp + 100;
        bytes32 structHash = keccak256(
            abi.encode(
                _PERMIT_TYPEHASH,
                _user,
                spender,
                permitAmount,
                rbt.nonces(_user),
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
        // (uint8 v, bytes32 r, bytes32 s) = vm.sign(10, hash);
        (v, r, s) = vm.sign(10, hash);
    }

    function testIncarnate() public {
        hoax(_user);
        bytes memory callData = abi.encodeWithSignature(
            "incarnate((uint256,uint256),address,uint256)",
            0.1 * 1 ether,
            0.5 * 1 ether,
            address(0),
            SOUP_PRICE
        );

        vm.expectRevert(InsufficientAmount.selector);
        payable(address(portal)).call{value: 0.1 ether}(callData);

        vm.prank(_user);
        (bool success, ) = payable(address(portal)).call{value: 0.61 * 1 ether}(
            callData
        );
        assertTrue(success);
    }

    function testEngrave(
        bytes32 seed,
        uint256 reward,
        uint256 score,
        uint256 age
    ) public {
        vm.assume(reward < rbt.cap() - 100 ether);
        mintRBT(rbt, owner, address(portal.vault()), reward);

        // testIncarnateWithPermit();
        testIncarnate();
        vm.expectEmit(true, true, true, true);
        emit Engrave(seed, _user, 1, score, reward);

        vm.prank(signer);
        portal.engrave(seed, _user, reward, score, age, 1, "@ElonMusk");
    }

    function mockEngrave() public returns (uint256 r) {
        r = ++_seedIndex;
        mintRBT(rbt, owner, address(portal.vault()), r);

        vm.prank(signer);
        portal.engrave(
            keccak256(abi.encode(r)),
            _user,
            r,
            r,
            r,
            r,
            "@DegenReborn"
        );
    }

    function mockEngraves(uint256 count) public {
        for (uint i = 0; i < count; i++) {
            mockEngrave();
        }
    }

    function mockEngravesAndInfuses(uint256 count) public {
        for (uint i = 0; i < count; i++) {
            uint256 t = mockEngrave();
            mockInfuse(_user, t, 1);
        }
    }

    // for test engrave gas
    function testManyEngraves() public {
        mockEngraves(500);
    }

    function testFuzzManyEngravesFuzz(uint256 count) public {
        mockEngraves(count);
    }

    function testInfuseNumericalValue(uint256 amount) public {
        vm.assume(amount < rbt.cap() - 100 ether);
        vm.assume(amount > 0);

        mintRBT(rbt, owner, _user, amount);

        vm.expectEmit(true, true, true, true);
        emit Infuse(_user, 1, amount);
        emit Transfer(_user, address(portal), amount);

        mockInfuse(_user, 1, amount);

        assertEq(portal.getPool(1).totalAmount, amount);
        assertEq(portal.getPortfolio(_user, 1).accumulativeAmount, amount);
    }

    function testBurnPool(uint256 amount) public {
        testInfuseNumericalValue(amount);
        assertEq(
            IERC20Upgradeable(address(rbt)).balanceOf(address(burnPool)),
            amount
        );

        vm.prank(owner);
        portal.burnFromBurnPool(amount);
        assertEq(
            IERC20Upgradeable(address(rbt)).balanceOf(address(burnPool)),
            0
        );
    }

    function mockInfuse(address user, uint256 tokenId, uint256 amount) public {
        mintRBT(rbt, owner, user, amount);

        vm.startPrank(user);
        rbt.approve(address(portal), amount);
        portal.infuse(tokenId, amount);
        vm.stopPrank();
    }

    function testInfuseWithPermit() public {
        uint256 amount = 1 ether;
        testEngrave(bytes32(new bytes(32)), 10, 10, 10);

        mintRBT(rbt, owner, _user, amount);

        (
            uint256 permitAmount,
            uint256 deadline,
            bytes32 r,
            bytes32 s,
            uint8 v
        ) = permitRBT(address(portal));
        vm.prank(_user);
        portal.infuse(1, amount, permitAmount, deadline, r, s, v);
    }

    function testSwitchPool() public {
        mintRBT(rbt, owner, address(portal.vault()), 2 * 1 ether);

        vm.startPrank(signer);
        portal.engrave(bytes32("0x1"), _user, 100, 10, 10, 10, "vitalik.eth");
        portal.engrave(
            bytes32("0x2"),
            _user,
            100,
            10,
            10,
            10,
            "cyberconnect.cc"
        );
        vm.stopPrank();

        // infuse pool 1
        mockInfuse(_user, 1, 0.5 * 1 ether);
        assertEq(portal.getPool(1).totalAmount, 0.5 * 1 ether);
        assertEq(
            portal.getPortfolio(_user, 1).accumulativeAmount,
            0.5 * 1 ether
        );

        // infuse pool 2
        mockInfuse(_user, 2, 1 ether);
        assertEq(portal.getPool(2).totalAmount, 1 ether);
        assertEq(portal.getPortfolio(_user, 2).accumulativeAmount, 1 ether);

        // switch pool 1 -> pool 2
        vm.prank(_user);
        portal.switchPool(1, 2, 0.1 * 1 ether);
        assertEq(portal.getPool(1).totalAmount, 0.4 * 1 ether);
        assertEq(
            portal.getPortfolio(_user, 1).accumulativeAmount,
            0.4 * 1 ether
        );
        assertEq(portal.getPool(2).totalAmount, 1.095 * 1 ether);
        assertEq(
            portal.getPortfolio(_user, 2).accumulativeAmount,
            1.095 * 1 ether
        );

        vm.expectRevert(SwitchAmountExceedBalance.selector);
        vm.prank(_user);
        portal.switchPool(1, 2, 0.5 * 1 ether);
    }

    function testTokenUri(
        bytes32 seed,
        uint208 reward,
        uint16 score,
        uint16 age
    ) public {
        testEngrave(seed, reward, score, age);
        string memory metadata = portal.tokenURI(1);
        console.log(metadata);
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
    }

    function testSeedRead(
        bytes32 seed,
        uint208 reward,
        uint16 score,
        uint16 age
    ) public {
        vm.assume(uint256(seed) > 1);
        testEngrave(seed, reward, score, age);

        assertEq(portal.seedExists(seed), true);
        assertEq(portal.seedExists(bytes32(uint256(seed) - 1)), false);
    }

    function testRewardReferrers() public {
        address ref1 = vm.addr(20);
        address ref2 = vm.addr(21);

        vm.prank(owner);
        portal.setReferrerRewardFee(800, 200, PortalLib.RewardType.NativeToken);

        // refer ref2->ref1
        hoax(ref1);
        incarnateWithReferrer(
            ref1,
            ref2,
            0.61 * 0.08 * 1e18,
            address(0),
            0,
            0.61 ether
        );

        // refer ref1->user
        vm.deal(ref1, 0);
        vm.deal(ref2, 0);
        hoax(_user);
        incarnateWithReferrer(
            _user,
            ref1,
            0.61 * 0.08 * 1e18,
            ref2,
            0.61 * 0.02 * 1e18,
            0.61 * 1 ether
        );
    }

    function incarnateWithReferrer(
        address account,
        address ref1,
        uint256 ref1Reward,
        address ref2,
        uint256 ref2Reward,
        uint256 amount
    ) public {
        vm.expectEmit(true, true, true, true);
        emit PortalLib.ReferReward(
            account,
            ref1,
            ref1Reward,
            ref2,
            ref2Reward,
            PortalLib.RewardType.NativeToken
        );
        payable(address(portal)).call{value: amount}(
            abi.encodeWithSignature(
                "incarnate((uint256,uint256),address,uint256)",
                0.1 ether,
                0.5 ether,
                ref1,
                SOUP_PRICE
            )
        );

        assertEq(ref1.balance, ref1Reward);
        assertEq(ref2.balance, ref2Reward);
    }

    function invariant_testToNextSeason() public {
        vm.prank(owner);
        portal.toNextSeason();

        assertEq(portal.paused(), true);
    }
}
