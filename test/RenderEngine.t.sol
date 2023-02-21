// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import "forge-std/Test.sol";
import "forge-std/Vm.sol";

import "src/lib/RenderEngine.sol";

contract RenderEngineTest is Test {
    function testRenderOne() public {
        string memory minSvg = vm.readFile("resources/RIP.new.min.svg");
        string memory svg = RenderEngine.render(
            hex"965f12d657ee47de669b9b94edcc47bbab9b886943233e46c81af970d72b6641",
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

    function testTransformBytes32Seed() public {
        assertEq(
            abi.encodePacked(
                "0x965f12d657ee",
                unicode"…",
                "33e46c81af970d72b6641"
            ),
            abi.encodePacked(
                RenderEngine._transformBytes32Seed(
                    hex"965f12d657ee47de669b9b94edcc47bbab9b886943233e46c81af970d72b6641"
                )
            )
        );
        assertEq(
            abi.encodePacked(
                "0x000000000000",
                unicode"…",
                "000000000000000001e62"
            ),
            abi.encodePacked(
                RenderEngine._transformBytes32Seed(
                    hex"0000000000000000000000000000000000000000000000000000000000001e62"
                )
            )
        );
    }
}
