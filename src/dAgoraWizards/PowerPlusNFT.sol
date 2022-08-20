/// @title A title that should describe the contract/interface
/// @author The name of the author
/// @notice Explain to an end user what this does
/// @dev Explain to a developer any extra details

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "@openzeppelin/contracts/token/common/ERC2981.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "ERC721A/ERC721A.sol";


contract PowerPlusNFT is 
    ERC721A,
    ERC2981,
    ReentrancyGuard,
    Ownable
{

    string public baseURI;
    string public baseExtension= ".json";

    bytes32 public merkleRoot;
    
    address public royaltyReceiver;

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
        uint96 _royaltyCut,
        address _newOwner,
        address _royaltyReceiver,
        bytes32 _merkleRoot
    ) ERC721A(_name, _symbol) {
        baseURI = _baseURI;
        royaltyReceiver = _royaltyReceiver;
        merkleRoot = _merkleRoot;
        maxAllowListAmount = _maxAllowListAmount;
        bulkBuyLimit = _bulkBuyLimit;
        mintCost = _mintCost;
        maxTotalSupply = _maxTotalSupply;
        transferOwnership(_newOwner);
        _setDefaultRoyalty(royaltyReceiver, _royaltyCut);
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

    modifier isPresale() {
        require(preSale == true, "Presale not active");
        _;
    }

    modifier isPublic() {
        require(!preSale, "Sale not Public");
        _;
    }

    function presaleMint(bytes32[] calldata _proof, uint256 _amount)
        public
        payable
        isPaused
        isPresale
        isValidMerkleProof(_proof, merkleRoot)
        nonReentrant
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

    function mintNFT(uint256 _amount) 
        public
        payable
        isPaused
        isPublic
        nonReentrant
    {
        require(_amount + totalSupply() <= maxTotalSupply, "Soldout");
        require(_amount <= bulkBuyLimit, "reached max per Tx");
        require(msg.value >= (_amount * mintCost), "Insufficient funds");

        for(uint256 i = 0; i < _amount; i++) {
            _safeMint(msg.sender, 1);
        }

    }

    function reserveTokens(uint256 _amount) 
        public 
        nonReentrant 
        onlyOwner
    {
        require(_amount + totalSupply() <= maxTotalSupply, "Soldout");
        for (uint256 i = 0; i < _amount; i++) {
            _safeMint(msg.sender, 1);
        }
    }

    function tokenURI(uint256 _tokenId) public view override returns (string memory) {
        require(_exists(_tokenId), "Token does not exist.");
        return string(abi.encodePacked(baseURI, _toString(_tokenId), baseExtension));
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

    function setBaseExtension(string memory _baseExtension)  public onlyOwner {
        baseExtension =  _baseExtension;
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

    function setMaxAllowListAmount(uint16 _newMaxAllowListAmount) public onlyOwner {
        maxAllowListAmount = _newMaxAllowListAmount;
    }

    function setRoyalties(address _receiver, uint96 _value) public onlyOwner{
        _setDefaultRoyalty(_receiver, _value);
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



