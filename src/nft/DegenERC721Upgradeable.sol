// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.17;

import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import "src/interfaces/nft/IDegenERC721Upgradeable.sol";

contract DegenERC721Upgradeable is ERC721Upgradeable, IDegenERC721Upgradeable {
    // Mapping from token ID to Properties
    mapping(uint256 => Properties) private properties;

    function _setProperties(
        uint256 tokenId,
        Properties calldata _properties
    ) internal {
        properties[tokenId] = _properties;
        emit SetProperties(_properties);
    }

    function propertyOf(
        uint256 tokenId
    ) public view returns (Properties memory) {
        return properties[tokenId];
    }
}
