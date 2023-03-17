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

    event Minted(address indexed to, uint256 indexed tokenId);
    event BaseURIChanged(string baseURI);
    event BaseExtensionChanged(string baseExtension);
    event MintCostChanged(uint256 mintCost);
    event BulkBuyLimitChanged(uint256 bulkBuyLimit);
    event MaxTotalSupplyChanged(uint256 maxTotalSupply);
    event PausedToggled(bool paused);
    
    constructor(
        string memory name_,
        string memory symbol_,
        string memory __baseURI,
        uint16 _bulkBuyLimit,
        uint256 _mintPrice,
        uint256 _maxSupply,
        address _newOwner
    ) ERC721A(name_, symbol_) {
        baseURI = __baseURI;
        baseExtension = '.json';
        mintPrice = _mintPrice;
        maxSupply = _maxSupply;
        bulkBuyLimit = _bulkBuyLimit;
        isPaused = true;
        transferOwnership(_newOwner);
    }

    /// @notice Modifier to check if the contract is paused
    /// @dev Throws if the contract is paused
    modifier isNotPaused() {
        require(!isPaused, "Contract is paused");
        _;
    }

    function mintNFT(uint256 amount) public payable isNotPaused nonReentrant {
        uint256 currentSupply = totalSupply();
        uint256 cost = mintPrice * amount;
        require(cost <= msg.value, "Insufficient funds");
        require(currentSupply + totalSupply() <= maxSupply, "Exceeds max supply");
        require(amount <= bulkBuyLimit, "Exceeds bulk buy limit");

        _mint(msg.sender, amount);
        emit Minted(msg.sender, amount);
    }

    function reserveTokens(uint256 amount) public onlyOwner nonReentrant {
        require(totalSupply() + amount <= maxSupply, "Exceeds max supply");
        require(amount <= bulkBuyLimit, "Exceeds bulk buy limit");
        _mint(owner(), amount);
        emit Minted(owner(), amount);
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        require(_exists(tokenId), "Token does not exist");
        return string(abi.encodePacked(baseURI, _toString(tokenId), baseExtension));
    }

    function setBaseURI(string memory _baseURI) public onlyOwner {
        baseURI = _baseURI;
        emit BaseURIChanged(baseURI);
    }

    function setBaseExtension(string memory _baseExtension) public onlyOwner {
        baseExtension = _baseExtension;
        emit BaseExtensionChanged(baseExtension);
    }

    function setMintPrice(uint256 _mintPrice) public onlyOwner {
        mintPrice = _mintPrice;
        emit MintCostChanged(mintPrice);
    }

    function setBulkBuyLimit(uint16 _bulkBuyLimit) public onlyOwner {
        bulkBuyLimit = _bulkBuyLimit;
        emit BulkBuyLimitChanged(bulkBuyLimit);
    }

    function togglePaused() public onlyOwner {
        isPaused = !isPaused;
        emit PausedToggled(isPaused);
    }

    function withdrawETH() public onlyOwner {
        uint256 balance = address(this).balance;
        payable(owner()).transfer(balance);
    }

    function withdrawERC20(address token) public onlyOwner {
        IERC20 erc20 = IERC20(token);
        uint256 balance = erc20.balanceOf(address(this));
        require(balance > 0, "No tokens to withdraw");
        erc20.transfer(owner(), balance);
    }

    function typeOf() public pure returns (string memory) {
        return "dAgora SimpleNFTA";
    }
    
    function _startTokenId() internal pure override returns (uint256) {
        return 1;
    }
}

