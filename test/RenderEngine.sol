// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import "forge-std/Test.sol";
import "forge-std/Vm.sol";

import "src/mock/RenderMock.sol";

contract RankTest is Test {
    RenderMock render;

    function setUp() public {
        render = new RenderMock();
    }

    function testRenderOne() public {
        string memory minSvg = vm.readFile("resources/RIP.min.svg");
        string memory svg = render.render(
            "7095f280-afa0-49c1-989a-3c9e8edd997b",
            74,
            9999,
            101,
            0x1E18EEEEeeeeEeEeEEEeEEEeEEeeEeeeeEeed8e5,
            256,
            466
        );
        assertEq(abi.encodePacked(minSvg), abi.encodePacked(svg));
    }
}
