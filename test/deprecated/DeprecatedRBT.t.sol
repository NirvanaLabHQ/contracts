// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.17;

import "src/deprecated/DeprecatedRBT.sol";
import "src/RBT.sol";

import "forge-std/Test.sol";
import "forge-std/Vm.sol";

contract DeprecatedRBTTest is Test {
    uint256 bnbMain;
    DeprecatedRBT drbt;
    DeprecatedRBT proxy;

    function setUp() public {
        string memory bnbMainRpcUrl = vm.envString("BNB_CHAIN_URL");
        bnbMain = vm.createFork(bnbMainRpcUrl);
        vm.selectFork(bnbMain);
        drbt = new DeprecatedRBT();
        proxy = DeprecatedRBT(0x8762b14181C435c297D8A2bd66AbeC09A8aE2233);
    }

    function testUpgradeAndSetMetadata() public {
        vm.startPrank(proxy.owner());
        proxy.upgradeTo(address(drbt));
        proxy.updateERC20MetaData(
            "Degen Reborn Token (Deprecated)",
            "$REBORN (deprecated)"
        );

        assertEq(proxy.name(), "Degen Reborn Token (Deprecated)");
        assertEq(proxy.symbol(), "$REBORN (deprecated)");
    }
}
