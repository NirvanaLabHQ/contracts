// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import "test/portal/RebornPortal.t.sol";
import {InvariantTest} from "forge-std/InvariantTest.sol";

import "test/portal/handler/InfuseHandler.sol";

contract RebornPortalInvar is RebornPortalBaseTest, InvariantTest {
    InfuseHandler internal _infuseHandler;

    function setUp() public override deployAll {
        _infuseHandler = new InfuseHandler(portal, rbt);
        targetContract(address(_infuseHandler));
    }

    /**
     * @dev pool's total amount equals the amount of each portofolio of this pool
     */
    function invariant_AddEveryPortofolioEqualPool() public {
        uint256[] memory wholeTokenIds = _infuseHandler.getWholeStakedPools();

        for (uint256 i = 0; i < wholeTokenIds.length; i++) {
            console.log(wholeTokenIds.length);
            uint256 tokenId = wholeTokenIds[i];
            uint256 totalAmount = portal.getPool(tokenId).totalAmount;

            address[] memory users = _infuseHandler.getPoolUsers(tokenId);

            console.log(users.length);

            uint256 sumAmount;

            for (uint256 j = 0; j < users.length; j++) {
                address user = users[j];
                console.log(user);
                sumAmount += portal
                    .getPortfolio(user, tokenId)
                    .accumulativeAmount;
            }

            assertEq(sumAmount, totalAmount);
        }
    }
}
