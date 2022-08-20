/// @title Simple ERC721A Minting Contract
/// @author Made By DecentrAgora
/// @notice use this contract to enhance you understand of the ERC721 Standard
/// @dev 0xOrphan || DadlessNsad

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "@openzeppelin/contracts/access/Ownable.sol";
import "ERC721A/ERC721A.sol";
import "@openzeppelin/contracts/token/common/ERC2981.sol";


contract PowerNFT is 
    ERC721A,
    ERC2981,
    Ownable 
{
    string public baseURI;
    string public baseExtension = ".json";

    bool public paused = true;              

    address public royaltyReceiver;
    
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
        uint96 _royaltyCut,
        address _newOwner,
        address _royaltyReceiver
    )
    ERC721A(_name, _symbol) 
    {
        baseURI = _baseURI;
        mintCost = _mintCost;
        royaltyReceiver = _royaltyReceiver;
        bulkBuyLimit = _bulkBuyLimit;
        maxTotalSupply = _maxTotalSupply;
        royaltyReceiver = _royaltyReceiver;

        transferOwnership(_newOwner);
        _setDefaultRoyalty(royaltyReceiver, _royaltyCut);
    }

    modifier isPaused() {
        require(!paused, "Contract is Paused");
        _;
    }

    function mintNFT(uint256 _amount)                
        public    
        payable      
        isPaused()
    {
        require(
            _amount <= bulkBuyLimit,
            "Max per tx"
        );
        require(
            (_amount + totalSupply()) <= maxTotalSupply,
            "Soldout"
        );
        require(
            (_amount * mintCost) <= msg.value,
            "Insufficient Eth sent"
        );

    _safeMint(msg.sender, _amount);
    }

    function reserveTokens(uint256 _quanitity)
        public 
        onlyOwner
    { 
        require(
            _quanitity + totalSupply() <= maxTotalSupply,
            "Soldout"
        );  
        _safeMint(msg.sender, _quanitity);
    }

    function tokenURI(uint256 _tokenId)
        public
        view 
        override 
        returns(string memory) 
    {
        require(
            _exists(_tokenId), 
            "Token does not exist."
    );
        return string(
            abi.encodePacked(
                baseURI,
                _toString(_tokenId),
                baseExtension
            )
        );
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(ERC721A, ERC2981)
        returns (bool)
    {
    return 
        ERC721A.supportsInterface(interfaceId) || 
        ERC2981.supportsInterface(interfaceId);
    }


    function setRoyalties(address _receiver, uint96 _value) public onlyOwner {
        _setDefaultRoyalty(_receiver, _value);
    }

    function setBaseURI(string memory _newBaseURI)
        public 
        onlyOwner 
    {
        baseURI = _newBaseURI;
    }

    function setBaseExtension(string memory _newBaseExtension)
        public
        onlyOwner
    {
        baseExtension = _newBaseExtension;
    }

    function setMintCost(uint256 _newMintCost) 
        public 
        onlyOwner 
    {
        mintCost = _newMintCost;
    }

    function setBulkBuyLimit(uint16 _newBulkBuyLimit) 
        public 
        onlyOwner 
    {
        bulkBuyLimit = _newBulkBuyLimit;
    }


    function togglePause() 
        public
        onlyOwner 
    {
        paused = !paused;
    }

    function withdraw() public onlyOwner {
        (bool success, ) = payable(msg.sender).call{
            value: address(this).balance
        }("");
        require(
            success, 
            "Address: unable to send value"
        );
    }

    function _startTokenId() 
        internal 
        view 
        virtual 
        override 
        returns(uint256)
    {
        return 1;
    }
}
