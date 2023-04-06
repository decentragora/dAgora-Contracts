// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import {ERC2981} from "@openzeppelin/contracts/token/common/ERC2981.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {ERC721A} from "erc721a/contracts/ERC721A.sol";

/// @title dAgora Power NFT
/// @author Made By DecentrAgora
/// @notice PowerNFT is ERC721A contract that is ownable and has royalties.
/// @dev This contract is used as a template for creating new NFT contracts.
contract PowerNFT is Ownable, ERC721A, ERC2981, ReentrancyGuard {
    /// @notice The base URI for all tokens.
    string public baseURI;

    /// @notice The file extension of the metadata can be set to nothing.
    /// @dev default value is json
    string public baseExtension;

    /// @notice The address that will receive the royalties.
    address public royaltyRecipient;

    /// @notice Boolean to determine if the contract is isPaused.
    /// @dev default value is true, contract is isPaused on deployment.
    bool public isPaused;

    /// @notice The cost to mint a token.
    uint256 public mintPrice;

    /// @notice The maximum number of tokens that can be minted.
    uint256 public maxSupply;
    
    /// @notice The maximum number of tokens that can be minted in a single transaction.
    uint16 public bulkBuyLimit;

    event Minted(address indexed to, uint256 indexed tokenId);
    event BaseURIChanged(string baseURI);
    event BaseExtensionChanged(string baseExtension);
    event MintCostChanged(uint256 mintPrice);
    event BulkBuyLimitChanged(uint16 bulkBuyLimit);
    event PausedToggled(bool isPaused);
    event RoyaltysChanged(address indexed royaltyRecipient, uint96 indexed royaltyBps);

    /// @notice The constructor for the PowerNFT contract.
    /// @param _name The name of the NFT.
    /// @param _symbol The symbol of the NFT.
    /// @param __baseURI The base URI for the NFT.
    /// @param _bulkBuyLimit The maximum number of tokens that can be minted in a single transaction.
    /// @param _royaltyBps The royalty percentage, is denominated by 10000.
    /// @param _mintPrice The cost to mint a token.
    /// @param _maxTotalSupply The maximum number of tokens that can be minted.
    /// @param _royaltyRecipient The address that will receive the royalties.
    /// @param _newOwner The address that will be the owner of the contract.
    constructor(
        string memory _name,
        string memory _symbol,
        string memory __baseURI,
        uint16 _bulkBuyLimit,
        uint96 _royaltyBps,
        uint256 _mintPrice,
        uint256 _maxTotalSupply,
        address _royaltyRecipient,
        address _newOwner
    ) ERC721A(_name, _symbol) {
        baseURI = __baseURI;
        bulkBuyLimit = _bulkBuyLimit;
        mintPrice = _mintPrice;
        maxSupply = _maxTotalSupply;
        royaltyRecipient = _royaltyRecipient;
        isPaused = true;
        baseExtension = ".json";        
        _setDefaultRoyalty(_royaltyRecipient, _royaltyBps);
        transferOwnership(_newOwner);
    }

    /// @notice Modifer to check if the contract is isPaused.
    modifier isNotPaused() {
        require(!isPaused, "PowerNFT: contract is paused");
        _;
    }

    /// @notice Function to Mint nfts.
    /// @param amount The number of tokens to mint.
    /// @dev The amount of tokens to mint must be less than or equal to the bulk buy limit, and contract must not be isPaused.
    function mintNFT(uint256 amount) public payable isNotPaused nonReentrant {
        require(amount <= bulkBuyLimit, "PowerNFT: exceeds bulk buy limit");
        require(totalSupply() + amount <= maxSupply, "PowerNFT: exceeds max supply");
        require(msg.value >= mintPrice * amount, "PowerNFT: insufficient funds");

        _safeMint(msg.sender, amount);
        emit Minted(msg.sender, amount);
    }

    /// @notice Function to reserve nfts.
    /// @param amount The number of tokens to mint.
    /// @dev only the owner can call this function.
    function reserveTokens(uint256 amount) public onlyOwner nonReentrant {
        require(totalSupply() + amount <= maxSupply, "PowerNFT: exceeds max supply");

        _safeMint(msg.sender, amount);
    }

    /// @notice returns the Uri for a token.
    /// @param tokenId The id of the token.
    /// @dev The token must exist.
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "PowerNFT: URI query for nonexistent token");
        return string(abi.encodePacked(baseURI, _toString(tokenId), baseExtension));
    }

    /// @notice OnlyOwner function to set the baseURI.
    /// @param __baseURI The base URI for the NFT.
    /// @dev only the owner can call this function.
    function setBaseURI(string memory __baseURI) public onlyOwner {
        baseURI = __baseURI;
        emit BaseURIChanged(baseURI);
    }

    /// @notice OnlyOwner function to set the baseExstension.
    /// @param _baseExtension The file extension of the metadata can be set to nothing.
    /// @dev only the owner can call this function.
    function setBaseExtension(string memory _baseExtension) public onlyOwner {
        baseExtension = _baseExtension;
        emit BaseExtensionChanged(baseExtension);
    }

    /// @notice OnlyOwner function to set the mint cost of a nft.
    /// @param _mintPrice The cost to mint a token.
    /// @dev only the owner can call this function.
    function setMintPrice(uint256 _mintPrice) public onlyOwner {
        mintPrice = _mintPrice;
        emit MintCostChanged(mintPrice);
    }

    /// @notice OnlyOwner function to set the bulk buy limit.
    /// @param _bulkBuyLimit The maximum number of tokens that can be minted in a single transaction.
    /// @dev only the owner can call this function.
    function setBulkBuyLimit(uint16 _bulkBuyLimit) public onlyOwner {
        bulkBuyLimit = _bulkBuyLimit;
        emit BulkBuyLimitChanged(bulkBuyLimit);
    }

    /// @notice OnlyOwner function to toggle the isPaused state of the contract.
    /// @dev only the owner can call this function.
    function togglePaused() public onlyOwner {
        isPaused = !isPaused;
        emit PausedToggled(isPaused);
    }

    /// @notice OnlyOwner function to set the royalties.
    /// @param _royaltyRecipient The address that will receive the royalties.
    /// @param _royaltyBps The royalty percentage, is denominated by 10000.
    /// @dev only the owner can call this function.
    function setRoyalties(address _royaltyRecipient, uint96 _royaltyBps) public onlyOwner {
        _setDefaultRoyalty(_royaltyRecipient, _royaltyBps);
        emit RoyaltysChanged(_royaltyRecipient, _royaltyBps);
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

    /// @notice OnlyOwner function to withdraw ETH.
    /// @dev only the owner can call this function.
    /// @dev the owner can withdraw the ETH from the contract.
    function withdrawETH() public onlyOwner {
        payable(owner()).transfer(address(this).balance);
    }

    /// @notice OnlyOwner function to withdraw ERC20 tokens.
    /// @param _tokenAddr The address of the ERC20 token.
    /// @dev only the owner can call this function.
    function withdrawERC20(address _tokenAddr) public onlyOwner {
        IERC20 erc20 = IERC20(_tokenAddr);
        uint256 balance = erc20.balanceOf(address(this));
        require(balance > 0, "PowerNFT: no tokens to withdraw");
        erc20.transfer(owner(), balance);    
    }


    /// @notice function that returns the dagora contract type
    /// @return the dagora contract type
    function typeOf() public pure virtual returns (string memory) {
        return "dAgora PowerNFT";
    }

    /// @notice function that returns the dagora contract version
    /// @return the dagora contract version
    function version() public pure returns (string memory) {
        return "1.0.0";
    }

    /// @notice internal function that handles that starting tokenId of the collection
    /// @return the starting tokenId of the collection eg 1
    function _startTokenId() internal view virtual override returns (uint256) {
        return 1;
    }
}