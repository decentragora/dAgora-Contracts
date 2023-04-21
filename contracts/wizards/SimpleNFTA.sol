// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.18;

import {ERC721A} from "erc721a/contracts/ERC721A.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract SimpleNFTA is ERC721A, Ownable, ReentrancyGuard {

    /// @notice State variable to track if the contract is paused
    bool public isPaused;

    /// @notice The base URI for all tokens
    string public baseURI;

    /// @notice The Extension at the end of the URI
    string public baseExtension;

    /// @notice The maximum number of tokens that can be minted in a single transaction
    uint16 public bulkBuyLimit;

    /// @notice The price of a single token
    uint256 public mintPrice;

    /// @notice The maximum number of tokens that can be minted
    uint256 public maxSupply;

    /// @notice the event that is emitted when a token is minted
    /// @param to The address that received the token
    /// @param tokenId The id of the token that was minted
    event Minted(address indexed to, uint256 indexed tokenId);

    /// @notice the event that is emitted when the baseURI is changed
    /// @dev The baseURI is the URI at the beginning of the tokenURI
    /// @param baseURI The new baseURI
    event BaseURIChanged(string baseURI);

    /// @notice the event that is emitted when the baseExtension is changed
    /// @dev The baseExtension is the extension at the end of the baseURI
    /// @param baseExtension The new baseExtension
    event BaseExtensionChanged(string baseExtension);

    /// @notice the event that is emitted when the mintPrice is changed
    /// @dev The mintPrice is the price of a single token can only be changed by the owner
    /// @param mintPrice The new mintPrice
    event MintCostChanged(uint256 mintPrice);

    /// @notice the event that is emitted when the bulkBuyLimit is changed
    /// @dev The bulkBuyLimit is the maximum number of tokens that can be minted in a single transaction
    /// @param bulkBuyLimit The new bulkBuyLimit
    event BulkBuyLimitChanged(uint256 bulkBuyLimit);

    /// @notice the event that is emitted when the contract is paused or unpaused
    /// @dev The contract can only be paused or unpaused by the owner
    /// @param paused The new paused state
    event PausedToggled(bool paused);
    

    /// @notice The constructor for the contract
    /// @param name_ The name of the token
    /// @param symbol_ The symbol of the token
    /// @param baseURI_ The base URI for the token
    /// @param _bulkBuyLimit The maximum number of tokens that can be minted in a single transaction
    /// @param _mintPrice The price of a single token
    /// @param _maxSupply The maximum number of tokens that can be minted
    /// @param _newOwner The address that will be the owner of the contract
    constructor(
        string memory name_,
        string memory symbol_,
        string memory baseURI_,
        uint16 _bulkBuyLimit,
        uint256 _mintPrice,
        uint256 _maxSupply,
        address _newOwner
    ) ERC721A(name_, symbol_) {
        baseURI = baseURI_;
        baseExtension = '.json';
        mintPrice = _mintPrice;
        maxSupply = _maxSupply;
        bulkBuyLimit = _bulkBuyLimit;
        isPaused = false;
        transferOwnership(_newOwner);
    }

    /// @notice Modifier to check if the contract is paused
    /// @dev Throws if the contract is paused
    modifier isNotPaused() {
        require(!isPaused, "Contract is paused");
        _;
    }

    /// @notice the function to mint nft tokens can be one or up to bulkBuyLimit
    /// @dev the function can only be called if the contract is not paused
    /// @param amount The number of tokens to mint can be one or up to bulkBuyLimit
    function mintNFT(address to, uint256 amount) public payable isNotPaused nonReentrant {
        require(amount > 0, "Amount must be greater than 0");
        require(to != address(0), "Cannot mint to address 0");
        require(totalSupply() + amount <= maxSupply, "Exceeds max supply");
        require(amount <= bulkBuyLimit, "Exceeds bulk buy limit");
        require(msg.value >= mintPrice * amount, "Insufficient funds");


        _mint(to, amount);
        emit Minted(to, amount);
    }

    /// @notice onlyOwner function to mint nft tokens can be one or up to bulkBuyLimit
    /// @dev the function can only be called if the contract is not paused
    /// @param amount The number of tokens to mint can be one or up to bulkBuyLimit
    function reserveTokens(uint256 amount) public onlyOwner nonReentrant {
        require(totalSupply() + amount <= maxSupply, "Exceeds max supply");
        require(amount <= bulkBuyLimit, "Exceeds bulk buy limit");
        _mint(owner(), amount);
        emit Minted(owner(), amount);
    }

    /// @notice function that returns the tokenURI for a given token
    /// @dev the function can only be called if the token exists
    /// @param tokenId The id of the token
    /// @return the tokenURI for the given token
    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        require(_exists(tokenId), "Token does not exist");
        return string(abi.encodePacked(baseURI, _toString(tokenId), baseExtension));
    }

    /// @notice onlyInOwner function to change the baseURI
    /// @dev the function can only be called by the owner
    /// @param _baseURI The new baseURI
    function setBaseURI(string memory _baseURI) public onlyOwner {
        baseURI = _baseURI;
        emit BaseURIChanged(baseURI);
    }

    /// @notice onlyInOwner function to change the baseExtension
    /// @dev the function can only be called by the owner
    /// @param _baseExtension The new baseExtension
    function setBaseExtension(string memory _baseExtension) public onlyOwner {
        baseExtension = _baseExtension;
        emit BaseExtensionChanged(baseExtension);
    }

    /// @notice onlyInOwner function to change the mintPrice
    /// @dev the function can only be called by the owner
    /// @param _mintPrice The new mintPrice
    function setMintPrice(uint256 _mintPrice) public onlyOwner {
        mintPrice = _mintPrice;
        emit MintCostChanged(mintPrice);
    }

    /// @notice onlyInOwner function to change the bulkBuyLimit
    /// @dev the function can only be called by the owner
    /// @param _bulkBuyLimit The new bulkBuyLimit
    function setBulkBuyLimit(uint16 _bulkBuyLimit) public onlyOwner {
        bulkBuyLimit = _bulkBuyLimit;
        emit BulkBuyLimitChanged(bulkBuyLimit);
    }

    /// @notice onlyInOwner function to change the isPaused state
    /// @dev the function can only be called by the owner
    function togglePaused() public onlyOwner {
        isPaused = !isPaused;
        emit PausedToggled(isPaused);
    }

    /// @notice onlyInOwner function to withdraw ETH from the contract
    /// @dev the function can only be called by the owner
    function withdrawETH() public onlyOwner {
        uint256 balance = address(this).balance;
        payable(owner()).transfer(balance);
    }

    /// @notice onlyInOwner function to withdraw ERC20 tokens from the contract
    /// @dev the function can only be called by the owner
    /// @param token The address of the ERC20 token
    function withdrawERC20(address token) public onlyOwner {
        IERC20 erc20 = IERC20(token);
        uint256 balance = erc20.balanceOf(address(this));
        require(balance > 0, "No tokens to withdraw");
        erc20.transfer(owner(), balance);
    }


    /// @notice internal override function that is called before any token transfer.
    /// @dev this function will revert if the contract is paused, pausing transfers of tokens.
    /// @param from The address of the sender.
    /// @param to The address of the receiver.
    /// @param tokenId The token ID.
    /// @param quantity The quantity of tokens to transfer.
    function _beforeTokenTransfers(
        address from,
        address to,
        uint256 tokenId,
        uint256 quantity
    ) internal override(ERC721A) {
        if (isPaused) {
            revert("Contract is paused");
        }
        super._beforeTokenTransfers(from, to, tokenId, quantity);
    }

    /// @notice function that returns the dagora contract type
    /// @return the dagora contract type
    function typeOf() public pure returns (string memory) {
        return "dAgora SimpleNFTA";
    }

    /// @notice function that returns the dagora contract version
    /// @return the dagora contract version
    function version() public pure returns (string memory) {
        return "1.0.0";
    }
    
    /// @notice internal function that handles that starting tokenId of the collection
    /// @return the starting tokenId of the collection eg 1
    function _startTokenId() internal pure override returns (uint256) {
        return 1;
    }
}

