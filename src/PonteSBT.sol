//SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@semaphore-protocol/contracts/interfaces/ISemaphore.sol";
import "@semaphore-protocol/contracts/interfaces/ISemaphoreVerifier.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol"; // Access control with roles more suitable for further versions

contract PonteSBT is Ownable(msg.sender) {
    struct Group {
        uint256 id;
        address nft;
        string uri;
    }

    ISemaphore public semaphore;
    ISemaphoreVerifier public verifier;

    mapping(uint256 => uint256) public ids; // semaphore group to groups array id mapping

    Group[] public groups;

    event ReviewSent(uint256 review, uint256 groupId);
    event MessageSent(uint256 message, uint256 groupId);
    

    constructor(address _semaphoreAddress, address _verifierAddress) {
        semaphore = ISemaphore(_semaphoreAddress);
        verifier = ISemaphoreVerifier(_verifierAddress);
    }

    function createGroup(
        uint256 _groupId,
        address _nftAddress,
        string calldata _uri
    ) external onlyOwner {
        semaphore.createGroup(_groupId, 20, address(this));
        groups.push(Group(_groupId, _nftAddress, _uri));
        ids[_groupId] = groups.length - 1; // check this
    }

    function joinGroup(
        address _nftAddress,
        uint256 _tokenId,
        uint256 _identityCommitment,
        uint256 _groupId
    ) external {
        require(
            IERC721(_nftAddress).ownerOf(_tokenId) == msg.sender,
            "You are not owner of NFT"
        );
        Group memory _group = getGroup(ids[_groupId]);
        require(_nftAddress == _group.nft, "NFT is not matching group NFT");
        semaphore.addMember(_groupId, _identityCommitment);
    }

    function sendReview(
        uint256 _groupId,
        uint256 _review,
        uint256 _merkleTreeRoot,
        uint256 _nullifierHash,
        uint256[8] calldata _proof
    ) external {
        semaphore.verifyProof(
            _groupId,
            _merkleTreeRoot,
            _review,
            _nullifierHash,
            _groupId,
            _proof
        );
        emit ReviewSent(_review,_groupId);
    }

    function sendMessage(
        uint256 _message,
        uint256 _nullifierHash,
        uint256 _groupId,
        uint256 _merkleTreeDepth,
        uint256 _merkleTreeRoot,
        uint256[8] calldata _proof
    ) external {
        // no need for nullifier, directly call verifier
        verifier.verifyProof(
            _merkleTreeRoot,
            _nullifierHash,
            _message,
            _groupId,
            _proof,
            _merkleTreeDepth
        );
        emit MessageSent(_message, _groupId);
    }

    function getGroup(uint _groupId) public view returns (Group memory) {
        return groups[_groupId];
    }
}
