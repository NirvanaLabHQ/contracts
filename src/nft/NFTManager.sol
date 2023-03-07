// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.17;

import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721URIStorageUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/CountersUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

import "src/interfaces/nft/INFTManager.sol";

contract NFTManager is
    ERC721URIStorageUpgradeable,
    OwnableUpgradeable,
    INFTManager
{
    using CountersUpgradeable for CountersUpgradeable.Counter;
    /**********************************************
     * storage
     **********************************************/

    CountersUpgradeable.Counter private _tokenIds;

    mapping(address => bool) public signers;

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
    function mint() public override onlyEOA {
        uint256 tokenId = _tokenIds.current();
        _mint(msg.sender, tokenId);
        _tokenIds.increment();

        emit Minted(msg.sender, tokenId);
    }

    /**
     * @inheritdoc INFTManager
     */
    function freeMint() external override onlySigner {}

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

    /**********************************************
     * internal functions
     **********************************************/

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
