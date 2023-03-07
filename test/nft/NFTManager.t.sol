// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import "forge-std/Test.sol";
import "src/nft/NFTManager.sol";
import "murky/Merkle.sol";

contract NFTManagerTest is Test {
    NFTManager nftManager;
    address owner;
    address signer;

    function setUp() public {
        owner = vm.addr(1);
        signer = vm.addr(2);

        nftManager = new NFTManager();
        _initialize();
    }

    function testUpdateSigners() public {
        _updateSigners();
        assertEq(nftManager.signers(signer), true);
    }

    function testAirdrop() public {
        _updateSigners();

        address[] memory receivers = new address[](4);
        receivers[0] = address(10);
        receivers[1] = address(11);
        receivers[2] = address(12);
        receivers[3] = address(13);

        vm.startPrank(signer);
        nftManager.airdrop(receivers);

        assertEq(nftManager.ownerOf(0), address(10));
        assertEq(nftManager.balanceOf(address(10)), 1);
        assertEq(nftManager.ownerOf(3), address(13));
        assertEq(nftManager.exists(4), false);
    }

    function testMint() public {
        Merkle m = new Merkle();
        bytes32[] memory data = new bytes32[](4);
        data[0] = keccak256(bytes.concat(keccak256(abi.encode(address(10)))));
        data[1] = keccak256(bytes.concat(keccak256(abi.encode(address(11)))));
        data[2] = keccak256(bytes.concat(keccak256(abi.encode(address(12)))));
        data[3] = keccak256(bytes.concat(keccak256(abi.encode(address(13)))));

        bytes32 root = m.getRoot(data);
        vm.prank(owner);
        nftManager.setMerkleRoot(root);
        bytes32[] memory proof = m.getProof(data, 2);
        vm.prank(address(12));
        nftManager.mint(proof);

        assertEq(nftManager.balanceOf(address(12)), 1);
        assertEq(nftManager.ownerOf(0), address(12));
    }

    function _initialize() internal {
        nftManager.initialize("TestNFT", "TNFT", owner);
    }

    function _updateSigners() internal {
        vm.prank(owner);

        address[] memory toAdd = new address[](1);
        toAdd[0] = signer;

        address[] memory toRemove = new address[](0);

        nftManager.updateSigners(toAdd, toRemove);
    }
}
