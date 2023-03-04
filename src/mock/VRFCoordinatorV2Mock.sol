// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

contract VRFCoordinatorV2Mock {
    uint256 private _idx;

    function requestRandomWords(
        bytes32 keyHash,
        uint64 subId,
        uint16 requestConfirmations,
        uint32 callbackGasLimit,
        uint32 numWords
    ) public returns (uint256) {
        return ++_idx;
    }
}
