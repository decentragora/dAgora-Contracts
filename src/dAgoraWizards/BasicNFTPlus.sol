/// @title A title that should describe the contract/interface
/// @author The name of the author
/// @notice Explain to an end user what this does
/// @dev Explain to a developer any extra details

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";


contract BasicNFTPlus is ERC721, Ownable {
    using Strings for string;
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIdCounter;

    string public baseURI;
    string public baseExtension = ".json";
    bytes32 public merkleRoot;

    bool public paused = true;
    bool public preSale = true;

    uint256 public maxAllowListAmount;
    uint256 public bulkBuyLimit;
    uint256 public mintCost;
    uint256 public maxTotalSupply;

    mapping(address => uint256) public presaleMintBalance;

    constructor(
        string memory _name,
        string memory _symbol,
        string memory _baseURI,
        uint256 _mintCost,
        uint16 _bulkBuyLimit,
        uint16 _maxAllowListAmount,
        uint256 _maxTotalSupply,
        address _newOwner,
        bytes32 _merkleRoot

    ) ERC721(_name, _symbol) {
        baseURI = _baseURI;
        mintCost = _mintCost;
        bulkBuyLimit = _bulkBuyLimit;
        maxAllowListAmount = _maxAllowListAmount;
        maxTotalSupply = _maxTotalSupply;
        merkleRoot = _merkleRoot;
        _tokenIdCounter = Counters.Counter(0);
        transferOwnership(_newOwner);
    }

    modifier isPaused() {
        require(!paused, "Contract is paused");
        _;
    }

    modifier isValidMerkleProof(bytes32[] calldata merkleProof, bytes32 root) {
        require(
            MerkleProof.verify(
            merkleProof,
            root,
            keccak256(abi.encodePacked(msg.sender))
        ),
        "Address does not exist in list"
        );
        _;
    }

    modifier isPreSale() {
        require(preSale == true, "Presale not active");
        _;
    }

    modifier isPublic() {
        require(!preSale, "Sale not Public");
        _;
    }

    function presaleMint(
        bytes32[] calldata _proof, 
        uint256 _amount
    )   public 
        payable
        isPaused
        isValidMerkleProof(_proof, merkleRoot)
        isPreSale
    {
        require(
            _amount + presaleMintBalance[msg.sender] <= maxAllowListAmount,
            "Reached max amount for whitelist"  
        );
        require((_tokenIdCounter.current() + _amount) <= maxTotalSupply, "Soldout");
        require(msg.value >= (_amount * mintCost), "Insufficient funds");

        for (uint256 i = 1; i <= _amount; i++) {
            _tokenIdCounter.increment();
            uint256 tokenId = _tokenIdCounter.current();
            presaleMintBalance[msg.sender] += _amount;
            _safeMint(msg.sender, tokenId);
        }
    }

    function mintNFT(uint256 _amount) 
        public 
        payable 
        isPaused
        isPublic
    {
        require(_amount <= bulkBuyLimit, "Over Max per Tx");
        require((_tokenIdCounter.current() + _amount) <= maxTotalSupply, "Soldout");
        require(msg.value >= (_amount * mintCost), "Insufficient funds");

        for (uint256 i = 1; i <= _amount; i++) {
            _tokenIdCounter.increment();
            uint256 tokenId = _tokenIdCounter.current();
            _safeMint(msg.sender, tokenId);
        }
    
    }

    function reserveTokens(uint256 _amount) public onlyOwner {
        require(_amount + totalSupply() <= maxTotalSupply, "Soldout");
        for (uint256 i = 1; i <= _amount; i++) {
            _tokenIdCounter.increment();
            _safeMint(msg.sender, _tokenIdCounter.current());
        }
    }

    function setMerkleRoot(bytes32 _merkleRoot) public onlyOwner {
        merkleRoot = _merkleRoot;
    }

    function togglePreSale() public onlyOwner {
        preSale = !preSale;
    }

    function togglePaused() public onlyOwner {
        paused = !paused;
    }

    function setBaseURI(string memory _baseURI) public onlyOwner {
        baseURI = _baseURI;
    }

    function setBaseExtension(string memory _newBaseExtension) public onlyOwner {
        baseExtension = _newBaseExtension;
    }

    function setMintCost(uint256 _newMintCost) public onlyOwner {
        mintCost = _newMintCost;
    }

    function setMaxAllowListAmount(uint256 _newMaxAllowListAmount) public onlyOwner {
        maxAllowListAmount = _newMaxAllowListAmount;
    }

    function setBulkBuyLimit(uint256 _newBulkBuyLimit) public onlyOwner {
        bulkBuyLimit = _newBulkBuyLimit;
    }

    function totalSupply() public view returns(uint256) {
        return _tokenIdCounter.current();
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

    function withdraw() public payable onlyOwner {
        (bool success, ) = payable(msg.sender).call{value: address(this).balance}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
}
