/// @title A title that should describe the contract/interface
/// @author The name of the author
/// @notice Explain to an end user what this does
/// @dev Explain to a developer any extra details

/// Spdx licenense idenitofeir
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";


contract BasicNFTOZ is ERC721, ERC721Enumerable, Ownable {
    using Strings for string;
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIdCounter;

    string public baseURI;
    string public baseExtension = ".json";

    bool public paused = true;

    uint256 public mintCost;
    uint16 public bulkBuyLimit;
    uint256 public maxTotalSupply;

    constructor(
        string memory _name,
        string memory _symbol,
        string memory _baseURI,
        uint256 _mintCost,
        uint16 _bulkBuyLimit,
        uint256 _maxTotalSupply,
        address _newOwner

    )   ERC721(_name, _symbol)
    {
        setBaseURI(_baseURI);
        setMintCost(_mintCost);
        bulkBuyLimit = _bulkBuyLimit;
        maxTotalSupply = _maxTotalSupply;
        transferOwnership(_newOwner);
    }

    modifier isPaused() {
        require(!paused, "Contract is paused");
        _;
    }

    function mintNFT(uint256 _amount) public payable isPaused {
        require(_amount <= bulkBuyLimit, "Over Max per Tx");
        require((totalSupply() + _amount) <= maxTotalSupply, "Soldout");
        require((_amount * mintCost) <= msg.value, "Insufficient funds");

        for (uint256 i = 1; i <= _amount; i++) {
            _tokenIdCounter.increment();
            uint256 tokenId = _tokenIdCounter.current();
            _safeMint(msg.sender, tokenId);
        }
    }

    function reserveTokens(uint256 _amount) public onlyOwner {
        require(
            _amount + totalSupply() <= maxTotalSupply,
            "Soldout"
        );

        for (uint256 i = 1; i <= _amount; i++) {
            _tokenIdCounter.increment();
            uint256 tokenId = _tokenIdCounter.current();
            _safeMint(msg.sender, tokenId);
        }
    }

    function tokenURI(uint256 _tokenId)
        public
        view
        virtual
        override
    returns (string memory)
    {
        require(
            _exists(_tokenId),
            "ERC721Metadata: URI query for nonexistent token"
        );
        string memory tokenId = Strings.toString(_tokenId);
        string memory currentBaseURI = baseURI;

        return bytes(currentBaseURI).length > 0
        ? string(abi.encodePacked(currentBaseURI, tokenId, baseExtension)) : "";   
    }


    function setBaseURI(string memory _baseURI) public onlyOwner {
        baseURI = _baseURI;
    }

    function setBaseExtension(string memory _newBaseExtension) 
        public
        onlyOwner
    {
        baseExtension = _newBaseExtension;
    }

    function setMintCost(uint256 _newMintCost) public onlyOwner {
        mintCost = _newMintCost;
    }

    function setBulkBuyLimit(uint16 _newBulkBuyLimit) public onlyOwner {
        bulkBuyLimit = _newBulkBuyLimit;
    }

    function togglePaused() public onlyOwner {
        paused = !paused;
    }

  // The following functions are overrides required by Solidity.
    function _beforeTokenTransfer(address from, address to, uint256 tokenId)
        internal
        override(ERC721, ERC721Enumerable)
    {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable)
        returns (bool)
   {
    return 
        ERC721.supportsInterface(interfaceId) || 
        ERC721Enumerable.supportsInterface(interfaceId);
    }

    function withdraw() public payable onlyOwner {
        (bool success, ) = payable(msg.sender).call{value: address(this).balance}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
}
