// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.17;

import "@openzeppelin/contracts-upgradeable/utils/cryptography/MerkleProofUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721URIStorageUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/CountersUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

import "src/interfaces/nft/INFTManager.sol";

contract NFTManager is
    ERC721URIStorageUpgradeable,
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
    function mint(bytes32[] calldata merkleProof) public override onlyEOA {
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

        _mintTo(msg.sender);
    }

    /**
     * @inheritdoc INFTManager
     */
    function airdrop(
        address[] calldata receivers
    ) external override onlySigner {
        for (uint256 i = 0; i < receivers.length; i++) {
            _mintTo(receivers[i]);
        }
    }

    /**
     * @inheritdoc INFTManager
     */
    function openMysteryBox(uint256 tokenId) external override {}

    function merge(uint256 tokenId1, uint256 tokenId2) external override {}

    function burn(uint256 tokenId) external override {}

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

    /**********************************************
     * read functions
     **********************************************/
    function exists(uint256 tokenId) external view returns (bool) {
        return _exists(tokenId);
    }

    /**********************************************
     * internal functions
     **********************************************/
    function _mintTo(address to) internal {
        uint256 tokenId = _tokenIds.current();

        if (tokenId >= TOTAL_MINT) {
            revert MintIsMaxedOut();
        }

        if (minted[to]) {
            revert AlreadyMinted();
        }

        _mint(to, tokenId);
        minted[to] = true;
        _tokenIds.increment();

        emit Minted(msg.sender, tokenId);
    }

    /**********************************************
     * modiriers
     **********************************************/
    modifier onlyEOA() {
        if (msg.sender != tx.origin) {
            revert OnlyEOA();
        }
        _;
    }

    modifier onlySigner() {
        if (!signers[msg.sender]) {
            revert NotSigner();
        }
        _;
    }
}
