// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import "forge-std/Test.sol";
import "src/nft/NFTManager.sol";
import "murky/Merkle.sol";
import "src/mock/ChainlinkVRFProxyMock.sol";
import "src/interfaces/nft/IDegenERC721Upgradeable.sol";

contract NFTManagerTest is Test {
    enum Rarity {
        Legendary,
        Epic,
        Rare,
        Uncommon,
        Common
    }

    enum TokenType {
        Standard,
        Shard
    }

    struct Properties {
        string name;
        Rarity rarity;
        TokenType tokenType;
    }

    NFTManager nftManager;
    ChainlinkVRFProxyMock chainlinkVRFProxyMock;
    address owner;
    address signer;

    function setUp() public {
        owner = vm.addr(1);
        signer = vm.addr(2);

        nftManager = new NFTManager();
        _initialize();
        _updateSigners();

        chainlinkVRFProxyMock = new ChainlinkVRFProxyMock();
        chainlinkVRFProxyMock.setController(address(nftManager));

        vm.prank(owner);
        nftManager.setBaseURI("https://www.baseuri.com/");
    }

    function testAirdrop() public {
        address[] memory receivers = _airdrop();
        assertEq(nftManager.ownerOf(1), receivers[0]);
        assertEq(nftManager.balanceOf(address(10)), 1);
        assertEq(nftManager.ownerOf(3), receivers[2]);
        assertEq(nftManager.getLatestTokenId(), 4);
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
        assertEq(nftManager.ownerOf(1), address(12));
    }

    function testSetMetadatas() public {
        _setMetadataList();
    }

    // function testOpenMysteryBox() public {
    //     // set metadata list
    //     _setMetadataList();
    //     // set current as chainlink proxy
    //     vm.prank(owner);
    //     nftManager.setChainlinkVRFProxy(address(chainlinkVRFProxyMock));
    //     _airdrop();
    //     // request random number
    //     vm.prank(signer);
    //     uint256[] memory tokenIds = _generateTokenIds();
    //     nftManager.openMysteryBox(tokenIds);

    //     console.log(nftManager.tokenURI(1));
    // }

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

    function _airdrop() internal returns (address[] memory) {
        address[] memory receivers = new address[](4);
        receivers[0] = address(10);
        receivers[1] = address(11);
        receivers[2] = address(12);
        receivers[3] = address(13);

        vm.prank(signer);
        nftManager.airdrop(receivers);
        return receivers;
    }

    function _setMetadataList() internal {
        IDegenERC721Upgradeable.Properties[]
            memory metadataList = new IDegenERC721Upgradeable.Properties[](4);
        metadataList[0] = IDegenERC721Upgradeable.Properties({
            name: "CZ",
            rarity: IDegenERC721Upgradeable.Rarity.Legendary,
            tokenType: IDegenERC721Upgradeable.TokenType.Shard
        });
        metadataList[0] = IDegenERC721Upgradeable.Properties({
            name: "CZ",
            rarity: IDegenERC721Upgradeable.Rarity.Legendary,
            tokenType: IDegenERC721Upgradeable.TokenType.Shard
        });
        metadataList[0] = IDegenERC721Upgradeable.Properties({
            name: "SBF",
            rarity: IDegenERC721Upgradeable.Rarity.Legendary,
            tokenType: IDegenERC721Upgradeable.TokenType.Shard
        });
        metadataList[0] = IDegenERC721Upgradeable.Properties({
            name: "SBF",
            rarity: IDegenERC721Upgradeable.Rarity.Legendary,
            tokenType: IDegenERC721Upgradeable.TokenType.Shard
        });

        vm.prank(owner);
        nftManager.setMetadatas(metadataList);
    }

    function _generateTokenIds() internal pure returns (uint256[] memory) {
        uint256[] memory tokenIds = new uint256[](4);
        tokenIds[0] = 1;
        tokenIds[1] = 2;
        tokenIds[2] = 3;
        tokenIds[3] = 4;
        return tokenIds;
    }
}
