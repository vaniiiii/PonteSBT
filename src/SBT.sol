//SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract SBT {
    error RMRKCannotTransferSoulbound();

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual override {
        if (!isTransferable(tokenId, from, to))
            revert RMRKCannotTransferSoulbound();

        super._beforeTokenTransfer(from, to, tokenId);
    }

    function isTransferable(
        uint256,
        address from,
        address to
    ) public view virtual returns (bool) {
        return ((from == address(0) || // Exclude minting
            to == address(0)) && from != to); // Exclude Burning // Besides the obvious transfer to self, if both are address 0 (general transferability check), it returns false
    }
}
