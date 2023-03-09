// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import "test/portal/RebornPortalBase.t.sol";

contract RebornPortalCommonTest is RebornPortalBaseTest {
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
        deal(address(rbt), address(portal.vault()), reward);

        // testIncarnateWithPermit();
        testIncarnate();
        vm.expectEmit(true, true, true, true);
        emit Engrave(seed, _user, 1, score, reward);

        vm.prank(signer);
        portal.engrave(seed, _user, reward, score, age, 1, "@ElonMusk");
    }

    // for test engrave gas
    function testManyEngravesIncre() public {
        mockEngravesIncre(500);
    }

    // for test engrave gas
    function testManyEngravesDecre() public {
        mockEngravesDecre(500);
    }

    function testInfuseNumericalValue(uint256 amount) public {
        vm.assume(amount < (rbt.cap() - 100 ether) / 2);
        vm.assume(amount > 0);

        vm.expectEmit(true, true, true, true);
        emit Infuse(_user, 1, amount);
        emit Transfer(_user, address(portal), amount);

        mockInfuse(_user, 1, amount);

        assertEq(portal.getPool(1).totalAmount, amount);
        assertEq(portal.getPortfolio(_user, 1).accumulativeAmount, amount);
    }

    function testBurnPool(uint256 amount) public {
        vm.assume(amount < rbt.cap() / 2);

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

    function testInfuseWithPermit() public {
        uint256 amount = 1 ether;
        testEngrave(bytes32(new bytes(32)), 10, 10, 10);

        deal(address(rbt), _user, amount);

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
        deal(address(rbt), address(portal.vault()), 2 * 1 ether);

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

        vm.expectRevert();
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
        deal(address(rbt), address(portal.vault()), amount);

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
}
