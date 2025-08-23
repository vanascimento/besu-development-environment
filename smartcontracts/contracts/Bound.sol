// SPDX-License-Identifier: MIT 
pragma solidity ^0.8.20;
import {ERC721URIStorage, ERC721} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

contract Bound is  ERC721URIStorage {
    uint256 private _nextTokenId;
    address private _owner;
    constructor() ERC721("Bound", "BOUND") {
        _owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == _owner, "Only owner can call this function");
        _;
    }

    function createBound(address boundOwner, string memory tokenURI) public onlyOwner {
        _nextTokenId++;
        _safeMint(boundOwner, _nextTokenId);
        _setTokenURI(_nextTokenId, tokenURI);
        
    }
}