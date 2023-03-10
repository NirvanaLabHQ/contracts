// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.17;

interface INFTManager {
    /**********************************************
     * errors
     **********************************************/
    error ZeroOwnerSet();
    error NotSigner();
    error MintIsMaxedOut();
    error AlreadyMinted();
    error ZeroRootSet();
    error InvalidProof();
    error NotTokenOwner();
    error InvalidTokens();

    /**********************************************
     * events
     **********************************************/
    event Minted(address indexed account, uint256 indexed tokenId);
    event SignerUpdate(address indexed signer, bool valid);
    event MerkleTreeRootSet(bytes32 root);
    // burn the tokenId of from account
    event MergeTokens(
        address indexed from,
        uint256 tokenId1,
        uint256 tokenId2,
        uint256 newTokenId
    );
    event BurnToken(address account, uint256 tokenId);

    /**********************************************
     * functions
     **********************************************/
    /**
     * @dev users in whitelist can mint mystery box
     */
    function mint(bytes32[] calldata merkleProof) external;

    /**
     * @dev signer mint and airdrop NFT to receivers
     */
    function airdrop(address[] calldata receivers) external;

    /**
     * @dev bind tokenId and metadata
     * @param tokenId tokenId wait to open
     */
    function openMysteryBox(uint256 tokenId) external;

    function merge(uint256 tokenId1, uint256 tokenId2) external;

    function burn(uint256 tokenId) external;

    function setMerkleRoot(bytes32 root) external;

    function exists(uint256 tokenId) external view returns (bool);
}
