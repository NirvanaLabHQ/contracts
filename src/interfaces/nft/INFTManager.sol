// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.17;

interface INFTManager {
    /**********************************************
     * errors
     **********************************************/
    error OnlyEOA();
    error ZeroOwnerSet();
    error NotSigner();

    /**********************************************
     * events
     **********************************************/
    event Minted(address indexed account, uint256 indexed tokenId);

    event SignerUpdate(address indexed signer, bool valid);

    /**
     * @dev users in whitelist can mint.mint mystery box
     */
    function mint() external;

    /**
     * @dev signer mint and airdrop to users
     */
    function freeMint() external;

    function merge(uint256 tokenId1, uint256 tokenId2) external;

    function burn(uint256 tokenId) external;
}
