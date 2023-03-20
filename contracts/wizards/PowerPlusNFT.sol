//SPDX-License-Identifier: MIT
/// @title dAgora Power Plus NFT
/// @author DadlessNsad || 0xOrphan
/// @notice Used as a template for creating new NFT contracts.
pragma solidity ^0.8.17;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {MerkleProof} from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import {ERC2981} from "@openzeppelin/contracts/token/common/ERC2981.sol";
import {ERC721A} from "erc721a/contracts/ERC721A.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";


/// @title dAgora Power Plus NFT
/// @author Made By DecentrAgora
/// @notice PowerPlusNFT is ERC721A contract that is ownable, has royalties, and a pre-sale.
/// @dev This contract is used as a template for creating new NFT contracts.
contract PowerPlusNFT is Ownable, ERC721A, ERC2981, ReentrancyGuard {

    struct Params {
        string name_;
        string symbol_;
        string baseURI_;
        uint16 _bulkBuyLimit;
        uint16 _maxAllowListAmount;
        uint96 _royaltyBps;
        uint256 _mintPrice;
        uint256 _presaleMintCost;
        uint256 _maxSupply;
        address _royaltyRecipient;
        address _newOwner;
        bytes32 _merkleRoot;
    }

    /// @notice The base URI for all tokens.
    string public baseURI;

    /// @notice The file extension of the metadata can be set to nothing.
    /// @dev default value is json
    string public baseExtension;

    /// @notice The address that will receive the royalties.
    address public royaltyRecipient;

    /// @notice Boolean to determine if the contract is paused.
    /// @dev default value is true, contract is paused on deployment.
    bool public isPaused;

    /// @notice Boolean to determine if the contract is in the pre-sale period.
    /// @dev default value is true, contract is in presale state on deployment.
    bool public preSaleActive;

    /// @notice The merkle root for the allowList.
    bytes32 public merkleRoot;

    /// @notice The maximum number of tokens that can be minted in a single transaction.
    uint16 public bulkBuyLimit;

    /// @notice The maximum number of tokens that can be minted in a single transaction for a whitelist address.
    /// @dev this is used during the whitelist period.
    uint16 public maxAllowListAmount;

    /// @notice The cost to mint a token.
    uint256 public mintPrice;

    /// @notice The cost to mint a token during the presale period.
    uint256 public presaleMintPrice;

    /// @notice The maximum number of tokens that can be minted.
    uint256 public maxSupply;


    event Minted(address indexed to, uint256 indexed tokenId);
    event AllowListMinted(address indexed to, uint256 indexed tokenId);
    event BaseURIChanged(string baseURI);
    event BaseExtensionChanged(string baseExtension);
    event MintCostChanged(uint256 mintPrice);
    event presaleMintPriceChanged(uint256 presaleMintPrice);
    event BulkBuyLimitChanged(uint16 bulkBuyLimit);
    event MaxAllowListAmountChanged(uint16 maxAllowListAmount);
    event PausedToggled(bool paused);
    event PreSaleToggled(bool preSaleActive);
    event RoyaltysChanged(address indexed royaltyRecipient, uint96 indexed royaltyBps);

    /// @notice Mapping to track the number of tokens minted for each address during presale.
    mapping(address => uint256) public allowListMintCount;

    /// @notice The constructor for the contract.
    /// @param _params The struct containing the parameters for the contract.
    constructor(
        Params memory _params
    ) ERC721A(_params.name_, _params.symbol_) {
        baseURI = _params.baseURI_;
        bulkBuyLimit = _params._bulkBuyLimit;
        maxAllowListAmount = _params._maxAllowListAmount;
        mintPrice = _params._mintPrice;
        presaleMintPrice = _params._presaleMintCost;
        maxSupply = _params._maxSupply;
        royaltyRecipient = _params._royaltyRecipient;
        merkleRoot = _params._merkleRoot;
        isPaused = true;
        preSaleActive = true;
        baseExtension = ".json";
        transferOwnership(_params._newOwner);
        _setDefaultRoyalty(_params._royaltyRecipient, _params._royaltyBps);
    }

    /// @notice Modifier to check if the contract is paused.
    modifier isNotPaused() {
        require(!isPaused, "Contract is paused");
        _;
    }

    /// @notice Modifier to check the address is allowed to mint during the presale period.
    /// @param merkleProof The merkle proof for the address.
    /// @param root The merkle root for the allowList.
    /// @dev check the proof provided against the root stored in the contract.
    modifier isValidMerkleProof(bytes32[] calldata merkleProof, bytes32 root) {
        require(
            MerkleProof.verify(merkleProof, root, keccak256(abi.encodePacked(msg.sender))),
            "Invalid merkle proof"
        );
        _;
    }

    /// @notice a modifier to check if the contract is in the public sale period.
    modifier isPublicSale() {
        require(!preSaleActive, "Presale is active");
        _;
    }


    /// @notice a modifier to check if the contract is in the presale period.
    modifier isPreSale() {
        require(preSaleActive, "Presale is not active");
        _;
    }

    /// @notice Fcuntion to mint nfts.
    /// @param amount The number of tokens to mint.
    /// @dev this function is used during the public sale period.
    function mintNFT(uint256 amount) public payable isNotPaused isPublicSale nonReentrant {
        require(amount <= bulkBuyLimit, "Exceeds bulk buy limit");
        require(totalSupply() + amount <= maxSupply, "Amount exceeds max supply");
        require(msg.value == mintPrice * amount, "Incorrect amount of ETH sent");
        _safeMint(msg.sender, amount);
        emit Minted(msg.sender, amount);
    }

    /// @notice Function to mint nfts during the presale period.
    /// @param _proof The merkle proof for the address.
    /// @param amount The number of tokens to mint.
    function presaleMintNFT(
        bytes32[] calldata _proof,
        uint256 amount
    )   public
        payable
        isNotPaused
        isPreSale
        isValidMerkleProof(_proof, merkleRoot)
        nonReentrant
    {
        require(amount + allowListMintCount[msg.sender] <= maxAllowListAmount, "Amount exceeds max allowList amount");
        require(totalSupply() + amount <= maxSupply, "Amount exceeds max supply");
        require(msg.value == presaleMintPrice * amount, "Incorrect amount of ETH sent");

        allowListMintCount[msg.sender] += amount;
        _safeMint(msg.sender, amount);
        emit AllowListMinted(msg.sender, amount);
    }

    /// @notice Function to mint nfts during the presale period.
    /// @param amount The number of tokens to mint.
    /// @dev this function is used to mint tokens for the team.
    function reserveTokens(uint256 amount) public onlyOwner nonReentrant {
        require(totalSupply() + amount <= maxSupply, "Amount exceeds max supply");
        _safeMint(msg.sender, amount);
    }

    /// @notice returns the token URI for a given token.
    /// @param tokenId The token ID.
    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        require(_exists(tokenId), "Token does not exist");
        return string(abi.encodePacked(baseURI, _toString(tokenId), baseExtension));
    }

    /// @notice Function to toggle the paused state of the contract.
    function togglePaused() public onlyOwner {
        isPaused = !isPaused;
        emit PausedToggled(isPaused);
    }

    /// @notice OnlyOwner Function to toggle the presale state of the contract.
    function togglePresale() public onlyOwner {
        preSaleActive = !preSaleActive;
        emit PreSaleToggled(preSaleActive);
    }

    /// @notice OnlyOwner Function to set the base URI for the token URIs.
    /// @param _base_URI The new base URI.
    function setBaseURI(string memory _base_URI) public onlyOwner {
        baseURI = _base_URI;
        emit BaseURIChanged(baseURI);
    }

    /// @notice OnlyOwner Function to set the base extension for the token URIs.
    /// @param _baseExtension The new base extension.
    function setBaseExtension(string memory _baseExtension) public onlyOwner {
        baseExtension = _baseExtension;
        emit BaseExtensionChanged(baseExtension);
    }

    /// @notice OnlyOwner Function to set the mint cost during the public sale period.
    /// @param _mintPrice The new mint cost during the public sale period.
    /// @dev this function is used to set the mint cost during the public sale period.
    function setMintPrice(uint256 _mintPrice) public onlyOwner {
        mintPrice = _mintPrice;
        emit MintCostChanged(mintPrice);
    }

    /// @notice OnlyOwner Function to set the mint cost during the presale period.
    /// @param _presaleMintPrice The new mint cost during the presale period.
    function setPresaleMintPrice(uint256 _presaleMintPrice) public onlyOwner {
        presaleMintPrice = _presaleMintPrice;
        emit presaleMintPriceChanged(_presaleMintPrice);
    }

    /// @notice OnlyOwner Function to set the bulk buy limit per transaction, during the public sale period.
    /// @param _bulkBuyLimit The new bulk buy limit.
    function setBulkBuyLimit(uint16 _bulkBuyLimit) public onlyOwner {
        bulkBuyLimit = _bulkBuyLimit;
        emit BulkBuyLimitChanged(_bulkBuyLimit);
    }

    /// @notice OnlyOwner Function to set the max allow list amount per address, during the presale period.
    /// @param _amount The new max allow list amount per address.
   function setMaxAllowListAmount(uint16 _amount) public onlyOwner {
        maxAllowListAmount = _amount;
        emit MaxAllowListAmountChanged(_amount);
    }


    /// @notice OnlyOwner Function to set the merkle root for the presale.
    /// @param _merkleRoot The new merkle root.
    /// @dev this function is used to set the merkle root for the presale, this is used to verify the merkle proof and check if a address is included.
    function setMerkleRoot(bytes32 _merkleRoot) public onlyOwner {
        merkleRoot = _merkleRoot;
    }

    /// @notice Function to set the royalties for the contract.
    /// @param _royaltyRecipient The new royalty recipient.
    /// @param _royaltyBps The new royalty bps, denominated by 10000.
    function setRoyalties(address _royaltyRecipient, uint96 _royaltyBps) public onlyOwner {
        _setDefaultRoyalty(_royaltyRecipient, _royaltyBps);
        emit RoyaltysChanged(_royaltyRecipient, _royaltyBps);
    }

    /// @notice OnlyOwner Function to withdraw ETH from the contract.
    function withdrawETH() public onlyOwner {
        uint256 balance = address(this).balance;
        payable(msg.sender).transfer(balance);
    }

    /// @notice OnlyOwner function to withdraw ERC20 tokens from the contract.
    /// @param _tokenAddr The address of the ERC20 token to withdraw.
    function withdrawERC20(address _tokenAddr) public onlyOwner {
        IERC20 erc20 = IERC20(_tokenAddr);
        uint256 balance = erc20.balanceOf(address(this));
        require(balance > 0, "No tokens to withdraw");
        erc20.transfer(owner(), balance);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override (ERC721A, ERC2981)
        returns (bool)
    {
        return ERC721A.supportsInterface(interfaceId)
            || ERC2981.supportsInterface(interfaceId);
    }

    function typeOf() public pure virtual returns (string memory) {
        return "dAgora PowerPlusNFT";
    }

    /// @notice Internal Function to set the starting tokenId of the contract.
    function _startTokenId() internal view virtual override returns (uint256) {
        return 1;
    }
}