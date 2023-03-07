// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import "src/RebornPortal.sol";

contract InfuseHandler {
    RebornPortal _portal;

    constructor(RebornPortal portal_) {
        _portal = portal_;
    }

    function infuse(uint256 tokenId, uint256 amount) external {
        _portal.infuse(tokenId, amount);
    }
}
