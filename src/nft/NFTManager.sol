// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.17;

import "@openzeppelin/contracts-upgradeable/utils/cryptography/MerkleProofUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/CountersUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/StringsUpgradeable.sol";

import "./DegenERC721URIStorageUpgradeable.sol";
import "src/interfaces/nft/INFTManager.sol";

contract NFTManager is
    DegenERC721URIStorageUpgradeable,
    OwnableUpgradeable,
    INFTManager
{
    uint256 public constant TOTAL_MINT = 2009;
    using CountersUpgradeable for CountersUpgradeable.Counter;
    /**********************************************
     * storage
     **********************************************/

    CountersUpgradeable.Counter private _tokenIds;

    mapping(address => bool) public signers;
    mapping(address => bool) public minted;

    // id => metadata map
    mapping(uint256 => Properties) metadatas;
    // latest index of metadata map
    uint16 public latestMetadataIdx;

    // white list merkle tree root
    bytes32 public merkleRoot;

    uint256[48] private _gap;

    /**********************************************
     * write functions
     **********************************************/
    function initialize(
        string memory name_,
        string memory symbol_,
        address owner
    ) public initializer {
        __ERC721_init_unchained(name_, symbol_);
        __ERC721URIStorage_init_unchained();
        __Ownable_init_unchained();
        _transferOwnership(owner);
    }

    /**
     * @inheritdoc INFTManager
     */
    function mint(bytes32[] calldata merkleProof) public override {
        bytes32 leaf = keccak256(
            bytes.concat(keccak256(abi.encode(msg.sender)))
        );

        bool verified = MerkleProofUpgradeable.verify(
            merkleProof,
            merkleRoot,
            leaf
        );

        if (!verified) {
            revert InvalidProof();
        }

        uint256 tokenId = _mintTo(msg.sender, true);

        emit Minted(msg.sender, tokenId);
    }

    /**
     * @inheritdoc INFTManager
     */
    function airdrop(
        address[] calldata receivers
    ) external override onlySigner {
        for (uint256 i = 0; i < receivers.length; i++) {
            uint256 tokenId = _mintTo(receivers[i], true);

            emit Minted(receivers[i], tokenId);
        }
    }

    /**
     * @inheritdoc INFTManager
     */
    function openMysteryBox(uint256 tokenId) external override {}

    function merge(uint256 tokenId1, uint256 tokenId2) external override {
        _checkOwner(msg.sender, tokenId1);
        _checkOwner(msg.sender, tokenId2);

        bool propertiEq = _checkPropertiesEq(tokenId1, tokenId2);
        if (!propertiEq) {
            revert InvalidTokens();
        }

        _burn(tokenId1);
        _burn(tokenId2);

        uint256 tokenId = _mintTo(msg.sender, false);
        _setTokenURI(
            tokenId,
            string.concat(StringsUpgradeable.toString(tokenId), ".json")
        );

        emit MergeTokens(msg.sender, tokenId1, tokenId2, tokenId);
    }

    function burn(uint256 tokenId) external override {
        _checkOwner(msg.sender, tokenId);

        _burn(tokenId);

        emit BurnToken(msg.sender, tokenId);
    }

    function updateSigners(
        address[] calldata toAdd,
        address[] calldata toRemove
    ) external onlyOwner {
        for (uint256 i = 0; i < toAdd.length; i++) {
            signers[toAdd[i]] = true;
            emit SignerUpdate(toAdd[i], true);
        }

        for (uint256 i = 0; i < toRemove.length; i++) {
            signers[toRemove[i]] = false;
            emit SignerUpdate(toRemove[i], false);
        }
    }

    // set white list merkler tree root
    function setMerkleRoot(bytes32 root) external override onlyOwner {
        if (root == bytes32(0)) {
            revert ZeroRootSet();
        }

        merkleRoot = root;

        emit MerkleTreeRootSet(root);
    }

    /**
     * @dev set id=>metadata map
     * latestMetadata is useed for compatible sence with multiple times to setting
     */
    function setMetadatas(
        Properties[] calldata metadataList
    ) external onlyOwner {
        for (uint256 i = 0; i < metadataList.length; i++) {
            metadatas[latestMetadataIdx] = metadataList[i];
            latestMetadataIdx++;
        }
    }

    /**********************************************
     * read functions
     **********************************************/
    function exists(uint256 tokenId) external view returns (bool) {
        return _exists(tokenId);
    }

    // get metadata config list
    function getMetadataList(
        uint16 length,
        uint256 offset
    ) external view returns (Properties[] memory) {
        Properties[] memory properties = new Properties[](length);
        for (uint256 i = offset; i < length; i++) {
            properties[i] = metadatas[i];
        }
        return properties;
    }

    /**********************************************
     * internal functions
     **********************************************/
    function _mintTo(
        address to,
        bool checkTotal
    ) internal returns (uint256 tokenId) {
        tokenId = _tokenIds.current();

        if (checkTotal) {
            if (tokenId >= TOTAL_MINT - 1) {
                revert MintIsMaxedOut();
            }

            if (minted[to]) {
                revert AlreadyMinted();
            }
        }

        _mint(to, tokenId);
        minted[to] = true;
        _tokenIds.increment();
    }

    function _checkOwner(address owner, uint256 tokenId) internal view {
        if (ownerOf(tokenId) != owner) {
            revert NotTokenOwner();
        }
    }

    // only name && tokenType equal means token1 and token2 can merge
    function _checkPropertiesEq(
        uint256 tokenId1,
        uint256 tokenId2
    ) internal view returns (bool) {
        Properties memory token1Property = propertyOf(tokenId1);
        Properties memory token2Property = propertyOf(tokenId2);

        return
            keccak256(bytes(token1Property.name)) ==
            keccak256(bytes(token2Property.name)) &&
            token1Property.tokenType == token2Property.tokenType;
    }

    /**********************************************
     * modiriers
     **********************************************/
    modifier onlySigner() {
        if (!signers[msg.sender]) {
            revert NotSigner();
        }
        _;
    }
}
