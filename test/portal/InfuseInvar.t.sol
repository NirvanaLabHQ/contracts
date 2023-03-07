// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import "test/portal/RebornPortal.t.sol";
import {InvariantTest} from "forge-std/InvariantTest.sol";

contract RebornPortalInvar is RebornPortalBaseTest, InvariantTest {
    function setUp() public override deployAll {}
}
