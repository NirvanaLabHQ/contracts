// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.17;

interface IChainlinkVRFProxy {
    function requestRandomWords(
        uint32 numWords,
        uint32 callbackGasLimit
    ) external returns (uint256 requestId);

    function getRequestIds() external view returns (uint256[] memory);

    function getReuqestStatus(
        uint256 requestId
    ) external view returns (bool fulfilled, uint256[] memory randomWords);
}
