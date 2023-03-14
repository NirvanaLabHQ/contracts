// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.17;

contract ChainlinkVRFProxyMock {
    address public controller;
    uint256 public counter;

    function setController(address controller_) public {
        controller = controller_;
    }

    function requestRandomWords(
        uint32 numWords,
        uint32 callbackGasLimit
    ) public {
        uint256 randomWord = uint256(
            keccak256(abi.encode(numWords, callbackGasLimit * (counter + 1)))
        );

        uint256[] memory randomWords = new uint256[](1);
        randomWords[0] = randomWord;

        fulfillRandomWords(randomWords);
        counter++;
    }

    function fulfillRandomWords(uint256[] memory randomWords) internal {
        controller.call(
            abi.encodeWithSignature(
                "fulfillRandomWordsCallback(uint256 requestId,uint256[] memory randomWords)",
                1,
                [randomWords]
            )
        );
    }
}
