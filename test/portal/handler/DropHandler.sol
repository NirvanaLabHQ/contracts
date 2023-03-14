// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import "forge-std/Test.sol";
import "forge-std/console.sol";

import "src/RebornPortal.sol";
import "src/interfaces/IRebornPortal.sol";
import "src/mock/VRFCoordinatorV2Mock.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

contract DropHandler is Test {
    RebornPortal internal _portal;
    RBT internal _rbt;
    address internal _vrfCoordinator;
    uint256 public dropCount;
    address internal _signer;

    uint256[] _words;

    address[] public actors;

    address internal currentActor;

    uint256 public initalJackPot;

    modifier useActor(uint256 actorIndexSeed) {
        currentActor = actors[bound(actorIndexSeed, 0, actors.length - 1)];
        vm.startPrank(currentActor);
        deal(address(_rbt), currentActor, type(uint256).max);
        _;
        vm.stopPrank();
    }

    function _initActors(uint256 amount) internal {
        for (uint256 i = 0; i < amount; i++) {
            actors.push(address(uint160(uint256(keccak256(abi.encode(i))))));
        }
    }

    constructor(
        RebornPortal portal_,
        RBT rbt_,
        address vrfCoordinator_,
        address signer_
    ) {
        _portal = portal_;
        _rbt = rbt_;
        _vrfCoordinator = vrfCoordinator_;
        _signer = signer_;

        // setDropConf
        _setDropConf();

        // mock infuse to to make
        _mockInfusesAndEngraves(200);

        // initialize random words
        _initWords();

        // initial actor
        _initActors(50);

        // incarnate to be added to jackpot
        _mockIncarnate();
    }

    function _mockIncarnate() internal {
        address _user = address(uint160(uint256(keccak256(abi.encode(9999)))));

        deal(_user, 10000 ether);

        vm.startPrank(_user);

        payable(address(_portal)).call{value: 1000 ether}(
            abi.encodeWithSignature(
                "incarnate((uint256,uint256),address,uint256)",
                0.1 ether,
                0.5 ether,
                address(1),
                0.1 ether
            )
        );

        vm.stopPrank();

        initalJackPot = 1000 ether;
    }

    function _setDropConf() internal {
        // set drop conf
        vm.prank(_portal.owner());
        _portal.setDropConf(
            PortalLib.AirdropConf(
                1,
                1 hours,
                3 hours,
                uint40(block.timestamp),
                uint40(block.timestamp),
                20,
                10,
                800,
                400
            )
        );
    }

    function _mockInfusesAndEngraves(uint256 count) internal {
        for (uint i = 1; i <= count; i++) {
            address _user = address(uint160(uint256(keccak256(abi.encode(i)))));

            // t
            _mockEngrave(_user, i);
            // infuse tokenId from 1 to 200, amount from 1 to 200
            _mockInfuse(_user, i, i);
        }
    }

    function _mockInfuse(
        address user,
        uint256 tokenId,
        uint256 amount
    ) internal {
        deal(address(_rbt), user, amount);
        vm.startPrank(user);
        _rbt.approve(address(_portal), amount);
        _portal.infuse(tokenId, amount);
        vm.stopPrank();
    }

    function _mockEngrave(address _user, uint256 i) internal {
        deal(address(_rbt), address(_portal.vault()), type(uint256).max);
        vm.prank(_signer);
        _portal.engrave(
            keccak256(abi.encode(i)),
            _user,
            i,
            i,
            i,
            i,
            "@DegenReborn"
        );
    }

    function drop() public {
        // set timestamp forward to trigger airdrop
        vm.warp(_portal.getDropConf()._rebornDropLastUpdate + 1 days);

        bool up;
        bytes memory perfromData;

        // request reborn token
        (up, perfromData) = _portal.checkUpkeep(new bytes(0));
        assertEq(up, true);
        assertEq(perfromData, abi.encode(1, 0));
        _portal.performUpkeep(perfromData);

        // request drop native
        (up, perfromData) = _portal.checkUpkeep(new bytes(0));
        assertEq(up, true);
        assertEq(perfromData, abi.encode(2, 0));
        _portal.performUpkeep(perfromData);

        //
        (up, perfromData) = _portal.checkUpkeep(new bytes(0));
        assertEq(up, false);

        // fulfill random number of the reborn request;
        vm.startPrank(_vrfCoordinator);
        _portal.rawFulfillRandomWords(
            VRFCoordinatorV2Mock(_vrfCoordinator)._idx() - 1,
            _words
        );
        vm.stopPrank();

        // fulfill random number of the native request;
        vm.startPrank(_vrfCoordinator);
        _portal.rawFulfillRandomWords(
            VRFCoordinatorV2Mock(_vrfCoordinator)._idx(),
            _words
        );
        vm.stopPrank();

        // perform the random number with reborn drop
        (up, perfromData) = _portal.checkUpkeep(new bytes(0));
        assertEq(up, true);
        _portal.performUpkeep(perfromData);

        // vm.expectEmit(false, false, false, false);
        // emit PortalLib.DropNative(199);
        // emit PortalLib.DropReborn(199);

        // perform the random number with native drop
        (up, perfromData) = _portal.checkUpkeep(new bytes(0));
        assertEq(up, true);
        assertEq(
            perfromData,
            abi.encode(4, VRFCoordinatorV2Mock(_vrfCoordinator)._idx())
        );
        _portal.performUpkeep(perfromData);

        // after all perform, upKeep should be false
        (up, perfromData) = _portal.checkUpkeep(new bytes(0));
        assertEq(up, false);

        dropCount += 1;

        console.log(dropCount);
    }

    function _initWords() internal {
        _words.push(1);
        _words.push(2);
        _words.push(3);
        _words.push(4);
        _words.push(5);
        _words.push(6);
        _words.push(7);
        _words.push(8);
        _words.push(9);
        _words.push(0);
    }
}
