//SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

// example of SBT, RMRK fork

contract SBT is ERC721, Ownable(msg.sender) {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIdCounter;
    error CannotTransferSoulbound();

    constructor() ERC721("SBT", "SBT") {
        _tokenIdCounter.increment(); // start from 1
    }

    function mint(address _receiver) external onlyOwner {
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(_receiver, tokenId);
    }

    function _beforeTokenTransfer(
        address _from,
        address _to,
        uint256 _tokenId,
        uint256 _batchSize
    ) internal override(ERC721) {
        if (!isTransferable(_from))
            revert CannotTransferSoulbound();
        super._beforeTokenTransfer(_from, _to, _tokenId, _batchSize);
    }

    function isTransferable(
        address _from
    ) public view virtual returns (bool) {
        return (_from == address(0)); // Exclude minting
    }
}
