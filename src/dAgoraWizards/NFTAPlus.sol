/// @title Simple ERC721A Minting Contract
/// @author Made By DecentrAgora
/// @notice use this contract to enhance you understand of the ERC721 Standard
/// @dev 0xOrphan || DadlessNsad

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;

import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "ERC721A/ERC721A.sol";

contract NFTAPlus is ERC721A, Ownable {

    string public baseURI;
    string public baseExtension;
    bytes32 public merkleRoot;

    bool public paused = true;
    bool public preSale = true;

    uint16 public maxAllowListAmount;
    uint16 public bulkBuyLimit;
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
    ) ERC721A(_name, _symbol) {
        baseURI = _baseURI;
        mintCost = _mintCost;
        bulkBuyLimit = _bulkBuyLimit;
        maxAllowListAmount = _maxAllowListAmount;
        maxTotalSupply = _maxTotalSupply;
        merkleRoot = _merkleRoot;
        transferOwnership(_newOwner);
    }

    modifier notPaused() {
        require(!paused, "Contract is Paused");
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

    modifier isPresale() {
        require(preSale == true, "Presale not active");
        _;
    }

    modifier isPublic() {
        require(!preSale, "Sale not Public");
        _;
    }
  
    function preSaleMint(bytes32[] calldata proof, uint256 _amount) 
        public
        payable
        notPaused
        isPresale
        isValidMerkleProof(proof, merkleRoot)
    {
        require(
            _amount + presaleMintBalance[msg.sender] <= maxAllowListAmount,
            "reach max amount for whitelsit"  
        );
        require(_amount + totalSupply() <= maxTotalSupply, "Soldout");
        require(msg.value >= (_amount * mintCost), "Insufficient funds");

        presaleMintBalance[msg.sender] += _amount;
        _safeMint(msg.sender, _amount);
    }

    function publicMint(uint256 _amount) 
        public 
        payable
        notPaused
        isPublic
    {
        require(_amount + totalSupply() <= maxTotalSupply, "Soldout");
        require(_amount <= bulkBuyLimit, "reached max per Tx");
        require(msg.value >= (_amount * mintCost), "Insufficient funds");
        
        _safeMint(msg.sender, _amount);
    }

    function reserveTokens(uint256 _amount) public onlyOwner {
        require(_amount + totalSupply() <= maxTotalSupply, "Soldout");
        _safeMint(msg.sender, _amount);
    }
  
    function tokenURI(uint256 _tokenId) public view override returns (string memory) {
        require(_exists(_tokenId), "Token does not exist.");
        return string(abi.encodePacked(baseURI, _toString(_tokenId),".json"));
    }

    function togglePaused() public onlyOwner {
        paused = !paused;
    }

    function togglePreSale() public onlyOwner {
        preSale = !preSale;
    }

    function setBaseURI(string memory _baseURI) public onlyOwner {
        baseURI = _baseURI;
    }

    function setBaseExtension(string memory _baseExtension) public onlyOwner {
        baseExtension = _baseExtension;
    }

    function setMerkleRoot(bytes32 _merkleRoot) public onlyOwner {
        merkleRoot = _merkleRoot;
    }

    function setMintCost(uint256 _mintCost) public onlyOwner {
        mintCost = _mintCost;
    }

    function setBulkBuyLimit(uint16 _newBulkBuyLimit) public onlyOwner {
        bulkBuyLimit = _newBulkBuyLimit;
    }

    function setMaxAllowListAmount(uint16 _newAllowListAmount) public onlyOwner {
        maxAllowListAmount = _newAllowListAmount;
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