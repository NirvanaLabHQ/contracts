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

contract RebornPortalBaseTest is Test, IRebornDefination, EventDefination {
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

    modifier deployAll() {
        // ignore effect of chainId to tokenId
        vm.chainId(0);

        rbt = TestUtils.deployRBT(owner);
        deal(address(rbt), _user, 100000 ether);

        // deploy vrf coordinator
        _vrfCoordinator = address(new VRFCoordinatorV2Mock());

        // deploy portal
        portal = deployPortal();
        vm.prank(owner);
        address[] memory toAdd = new address[](1);
        toAdd[0] = signer;
        address[] memory toRemove;
        portal.updateSigners(toAdd, toRemove);
        vm.prank(owner);
        portal.setExtraReward(8 ether);

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
        _;
    }

    function setUp() public virtual deployAll {}

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

    function mockEngraveFromLowToHigh() public returns (uint256 r) {
        r = ++_seedIndex;
        deal(address(rbt), address(portal.vault()), r);

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

    function mockEngraveFromHighToLow() public returns (uint256 r) {
        r = 1 ether - ++_seedIndex;
        deal(address(rbt), address(portal.vault()), r);

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

    function mockEngravesIncre(uint256 count) public {
        for (uint i = 0; i < count; i++) {
            mockEngraveFromLowToHigh();
        }
    }

    function mockEngravesDecre(uint256 count) public {
        for (uint i = 0; i < count; i++) {
            mockEngraveFromHighToLow();
        }
    }

    function mockEngravesAndInfuses(uint256 count) public {
        for (uint i = 0; i < count; i++) {
            uint256 t = mockEngraveFromLowToHigh();
            mockInfuse(_user, t, 1);
        }
    }

    function mockInfuse(address user, uint256 tokenId, uint256 amount) public {
        deal(address(rbt), user, amount);

        vm.startPrank(user);
        rbt.approve(address(portal), amount);
        portal.infuse(tokenId, amount);
        vm.stopPrank();
    }
}
