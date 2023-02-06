// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.17;

import "src/lib/RenderEngine.sol";

contract MockRender {
    function render() public pure returns (string memory) {
        return RenderEngine.render();
    }
}
