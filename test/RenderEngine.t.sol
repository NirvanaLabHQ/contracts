// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import "forge-std/Test.sol";
import "forge-std/Vm.sol";

import "src/lib/RenderEngine.sol";

contract RenderEngineTest is Test {
    function testRenderOne() public {
        string memory minSvg = vm.readFile("resources/RIP.new.min.svg");
        string memory svg = RenderEngine.render(
            "7095f280-afa0-49c1-989a-3c9e8edd997b",
            2222222,
            9999,
            101,
            0x1E18EEEEeeeeEeEeEEEeEEEeEEeeEeeeeEeed8e5,
            222222
        );
        assertEq(abi.encodePacked(minSvg), abi.encodePacked(svg));
    }

    function testTransformUint256() public {
        assertEq(
            abi.encodePacked("222"),
            abi.encodePacked(RenderEngine._transformUint256(222))
        );
        assertEq(
            abi.encodePacked("2,222"),
            abi.encodePacked(RenderEngine._transformUint256(2222))
        );
        assertEq(
            abi.encodePacked("222,222"),
            abi.encodePacked(RenderEngine._transformUint256(222222))
        );
        assertEq(
            abi.encodePacked("2,222,222"),
            abi.encodePacked(RenderEngine._transformUint256(2222222))
        );
    }
}
