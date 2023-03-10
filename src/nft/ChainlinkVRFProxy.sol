// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.17;

import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";
import "@chainlink/contracts/src/v0.8/ConfirmedOwner.sol";

contract ChainlinkVRF is VRFConsumerBaseV2, ConfirmedOwner {
    struct RequestStatus {
        bool fulfilled;
        bool exists;
        uint256[] randomWords;
    }

    event RequestRandomWords(uint256 requestId);
    event FulfilledRandomWords(uint256 requestId, uint256[] randomWords);

    /**
     * @dev controller of current proxy. onlyOwner means only controller
     * @notice must be contract with implament function
     * `fulfillRandomWordsCallback(uint256 requestId,uint256[] memory randomWords)`
     */
    address controller;

    uint64 subscriptionId;

    uint16 requestConfirmations;

    VRFCoordinatorV2Interface public coordinator;

    bytes32 public keyHash;

    uint256 public latestRequestId;

    uint256[] public requestIds;

    mapping(uint256 => RequestStatus) public requests;

    constructor(
        address controller_, // control contract
        address consumer_,
        address coordinator_,
        bytes32 keyHash_
    ) VRFConsumerBaseV2(consumer_) ConfirmedOwner(controller_) {
        require(
            controller_ != address(0),
            "Ownable: controller is the zero address"
        );
        require(coordinator_ != address(0), "coordinator is the zero address");
        require(keyHash != bytes32(0), "keyHash is bytes32(0)");
        controller = controller_;
        coordinator = VRFCoordinatorV2Interface(coordinator_);
        keyHash = keyHash_;
    }

    function requestRandomWords(
        uint32 numWords,
        uint32 callbackGasLimit
    ) external onlyOwner returns (uint256 requestId) {
        requestId = coordinator.requestRandomWords(
            keyHash,
            subscriptionId,
            requestConfirmations,
            callbackGasLimit,
            numWords
        );
        requests[requestId] = RequestStatus({
            fulfilled: false,
            exists: true,
            randomWords: new uint256[](0)
        });
        requestIds.push(requestId);
        latestRequestId = requestId;

        emit RequestRandomWords(requestId);
    }

    /**
     * @notice owner must implament
     * fulfillRandomWordsCallback(uint256 _requestId,uint256[] memory randomWords) function to receive randomWords
     * @dev receive randomWords from chainlink and notify owner
     * @param requestId requestId of randomwords
     * @param randomWords random words of requestId return from chainlink vrf
     */
    function fulfillRandomWords(
        uint256 requestId,
        uint256[] memory randomWords
    ) internal override {
        require(requests[requestId].exists, "request not found");

        requests[requestId].fulfilled = true;
        requests[requestId].randomWords = randomWords;

        controller.call(
            abi.encodeWithSignature(
                "fulfillRandomWordsCallback(uint256 requestId,uint256[] memory randomWords)",
                requestId,
                randomWords
            )
        );

        emit FulfilledRandomWords(requestId, randomWords);
    }

    function getRequestIds() external view returns (uint256[] memory) {
        return requestIds;
    }

    function getReuqestStatus(
        uint256 requestId
    ) external view returns (bool fulfilled, uint256[] memory randomWords) {
        require(requests[requestId].exists, "requestId not exists");

        RequestStatus memory status = requests[requestId];
        return (status.fulfilled, status.randomWords);
    }
}
