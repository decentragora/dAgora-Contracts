/// @title Simple ERC721A Minting Contract
/// @author Made By DecentrAgora
/// @notice use this contract to enhance you understand of the ERC721 Standard
/// @dev 0xOrphan || DadlessNsad

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;

import "@openzeppelin/contracts/access/Ownable.sol";
import "ERC721A/ERC721A.sol";

contract SimpleNFTA is ERC721A, Ownable {  

    string public baseURI;
    string public baseExtension = ".json";

    bool public paused = true;              

    uint256 public mintCost;
    uint256 public bulkBuyLimit;
    uint256 public maxTotalSupply;    

    constructor(
        string memory _name,
        string memory _symbol,
        string memory _baseURI,
        uint256 _mintCost,
        uint256 _bulkBuyLimit,
        uint256 _maxTotalSupply,
        address _newOwner
    )
    ERC721A(_name, _symbol) 
    {
        baseURI = _baseURI;
        mintCost = _mintCost;
        bulkBuyLimit = _bulkBuyLimit;
        maxTotalSupply = _maxTotalSupply;
        transferOwnership(_newOwner);
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
            "Insufficent Eth sent"
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

    function setBaseURI(string memory _newBaseURI)
        public 
        onlyOwner 
    {
        baseURI = _newBaseURI;
    }


    function setMintCost(uint256 _newMintCost) 
        public 
        onlyOwner 
    {
        mintCost = _newMintCost;
    }

    function setBulkBuyLimit(uint256 _newBulkBuyLimit) 
        public 
        onlyOwner 
    {
        bulkBuyLimit = _newBulkBuyLimit;
    }

    function setBaseExtension(string memory _newBaseExtension)
        public
        onlyOwner
    {
        baseExtension =_newBaseExtension;
    }

    function togglePaused()
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

    function withdrawErc20s(address _tokenAddr) public onlyOwner {
        (bool success, ) = payable(msg.sender).call{
            value: address(_tokenAddr).balance
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
