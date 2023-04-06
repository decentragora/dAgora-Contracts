// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.18;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {MerkleProof} from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import {ERC721A} from "erc721a/contracts/ERC721A.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract NFTAPlus is ERC721A, Ownable, ReentrancyGuard {

    /// @notice Boolean to determine if the contract is isPaused.
    /// @dev default value is true, contract is isPaused on deployment.
    bool public isPaused;

    /// @notice Boolean to determine if the contract is in the presale period.
    /// @dev default value is true.
    bool public isPresale;

    /// @notice The base URI for all tokens.
    string public baseURI;

    /// @notice The file extension of the metadata can be set to nothing.
    /// @dev default value is json
    string public baseExtension;

    /// @notice The merkle root for the allowList, this is used to verify the allowList.
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
    event PresaleMinted(address indexed to, uint256 indexed tokenId);
    event BaseURIChanged(string baseURI);
    event BaseExtensionChanged(string baseExtension);
    event MintCostChanged(uint256 mintPrice);
    event PresaleMintCostChanged(uint256 presaleMintCost);
    event BulkBuyLimitChanged(uint16 bulkBuyLimit);
    event MaxAllowListAmountChanged(uint16 maxAllowListAmount);
    event isPausedToggled(bool isPaused);
    event PresaleToggled(bool isPresale);

    mapping(address => uint256) public allowListMintCount;

    constructor(
        string memory _name,
        string memory _symbol,
        string memory __baseURI,
        uint16 _bulkBuyLimit,
        uint16 _maxAllowListAmount,
        uint256 _mintCost,
        uint256 _presaleMintCost,
        uint256 _maxTotalSupply,
        address _newOwner,
        bytes32 _merkleRoot
    ) ERC721A(_name, _symbol) {
        baseURI = __baseURI;
        baseExtension = ".json";
        bulkBuyLimit = _bulkBuyLimit;
        maxAllowListAmount = _maxAllowListAmount;
        mintPrice = _mintCost;
        presaleMintPrice = _presaleMintCost;
        maxSupply = _maxTotalSupply;
        isPaused = true;
        isPresale = true;
        merkleRoot = _merkleRoot;
        transferOwnership(_newOwner);
    }

    /// @notice Modifier to check if the contract is isPaused.
    /// @dev Throws if the contract is isPaused.
    modifier isNotPaused() {
        require(!isPaused, "Contract is paused");
        _;
    }

    /// @notice Modifier to check the sale state of the contract.
    /// @dev Throws if the contract is not in the presale period.
    modifier _isPresale() {
        require(isPresale, "Contract is not in presale");
        _;
    }

    /// @notice Modifier to check the sale state of the contract.
    /// @dev Throws if the contract is not in the public sale period.
    modifier isPublicSale() {
        require(!isPresale, "Contract is not in public sale");
        _;
    }

    /// @notice Modifier to check the proof of the allowList.
    /// @dev Throws if the proof is invalid.
    modifier isValidMerkleProof(bytes32[] calldata merkleProof, bytes32 root) {
        require(
            MerkleProof.verify(merkleProof, root, keccak256(abi.encodePacked(msg.sender))),
            "Invalid merkle proof"
        );
        _;
    }

    /// @notice This function is used to mint a token.
    /// @dev this function is only callable when the contract is not paused, and the sale is public.
    /// @param amount the amount of tokens to mint.
    function mintNFT(uint256 amount) public payable isNotPaused isPublicSale nonReentrant {
        require(amount <= bulkBuyLimit, "Exceeds bulk buy limit");
        require(totalSupply() + amount <= maxSupply, "Amount exceeds max supply");
        require(msg.value == mintPrice * amount, "Incorrect amount of ETH sent");
        _mint(msg.sender, amount);
        emit Minted(msg.sender, amount);
    }

    /// @notice This function is used to mint a token during the presale period.
    /// @dev this function is only callable when the contract is not paused, and the sale is presale.
    /// @param proof the merkle proof to check against the stored root.
    /// @param amount the amount of tokens to mint.
    function presaleMintNFT(
        bytes32[] calldata proof,
        uint256 amount
    )   public
        payable
        _isPresale
        isNotPaused
        nonReentrant
        isValidMerkleProof(proof, merkleRoot)
    {
        require(amount + allowListMintCount[msg.sender] <= maxAllowListAmount, "Amount exceeds max allowList amount");
        require(totalSupply() + amount <= maxSupply, "Amount exceeds max supply");
        require(msg.value == presaleMintPrice * amount, "Incorrect amount of ETH sent");
        allowListMintCount[msg.sender] += amount;
        _mint(msg.sender, amount);
        emit PresaleMinted(msg.sender, amount);
    }

    /// @notice OnlyOwner function to mint tokens.
    /// @dev this function is only callable by the owner of the contract.
    /// @param amount the amount of tokens to mint.
    function reserveTokens(uint256 amount) external onlyOwner {
        require(totalSupply() + amount <= maxSupply, "Exceeds max supply");
        require(amount <= bulkBuyLimit, "Exceeds bulk buy limit");
        _safeMint(msg.sender, amount);
        emit Minted(msg.sender, amount);
    }

    /// @notice returns the tokenURI for a given token.
    /// @dev this function is only callable when the token exists.
    /// @param tokenId the tokenID to get the tokenURI for.
    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        require(_exists(tokenId), "Token does not exist");
        return string(abi.encodePacked(baseURI, _toString(tokenId), baseExtension));
    }

    /// @notice Onlyowner function to set the base URI.
    /// @dev this function is only callable by the owner of the contract.
    /// @param __baseURI the base URI to set.
    function setBaseURI(string memory __baseURI) external onlyOwner {
        baseURI = __baseURI;
        emit BaseURIChanged(baseURI);
    }

    /// @notice Onlyowner function to set the base extension.
    /// @dev this function is only callable by the owner of the contract.
    /// @param _baseExtension the base extension to set.
    function setBaseExtension(string memory _baseExtension) external onlyOwner {
        baseExtension = _baseExtension;
        emit BaseExtensionChanged(_baseExtension);
    }

    /// @notice Onlyowner function to set the mint price for the public sale.
    /// @dev this function is only callable by the owner of the contract.
    /// @param _mintPrice the mint cost to set.
    function setMintPrice(uint256 _mintPrice) external onlyOwner {
        mintPrice = _mintPrice;
        emit MintCostChanged(mintPrice);
    }

    /// @notice Onlyowner function to set the mint price for the presale.
    /// @dev this function is only callable by the owner of the contract.
    /// @param _presaleMintPrice the presale mint cost to set.
    function setPresaleMintPrice(uint256 _presaleMintPrice) external onlyOwner {
        presaleMintPrice = _presaleMintPrice;
        emit PresaleMintCostChanged(presaleMintPrice);
    }

    /// @notice Onlyowner function to set the bulk buy limit.
    /// @dev this function is only callable by the owner of the contract.
    /// @param _bulkBuyLimit the bulk buy limit to set.
    function setBulkBuyLimit(uint16 _bulkBuyLimit) external onlyOwner {
        bulkBuyLimit = _bulkBuyLimit;
        emit BulkBuyLimitChanged(_bulkBuyLimit);
    }

    /// @notice Onlyowner function to set the max amount of tokens that can be minted during the presale.
    /// @dev this function is only callable by the owner of the contract.
    /// @param _maxAllowListAmount the max amount of tokens that can be minted during the presale.
    function setMaxAllowListAmount(uint16 _maxAllowListAmount) external onlyOwner {
        maxAllowListAmount = _maxAllowListAmount;
        emit MaxAllowListAmountChanged(_maxAllowListAmount);
    }

    /// @notice Onlyowner function to set the paused state of the contract.
    /// @dev this function is only callable by the owner of the contract.
    function togglePaused() external onlyOwner {
        isPaused = !isPaused;
        emit isPausedToggled(isPaused);
    }

    /// @notice Onlyowner function to set the presale state of the contract.
    /// @dev this function is only callable by the owner of the contract.
    function togglePresale() external onlyOwner {
        isPresale = !isPresale;
        emit PresaleToggled(isPresale);
    }

    /// @notice Onlyowner function to withdraw any ETH sent to the contract.
    /// @dev this function is only callable by the owner of the contract.
    function withdrawETH() external onlyOwner {
        uint256 balance = address(this).balance;
        payable(msg.sender).transfer(balance);
    }

    /// @notice Allows owner to withdraw any ERC20 tokens sent to this contract.
    /// @param _tokenAddr The address of the ERC20 token.
    /// @dev Only Contract Owner can use this function.
    function withdrawERC20(address _tokenAddr) public onlyOwner {
        IERC20 erc20 = IERC20(_tokenAddr);
        uint256 balance = erc20.balanceOf(address(this));
        require(balance > 0, "No tokens to withdraw");
        erc20.transfer(owner(), balance);
    }

    /// @notice function that returns the dagora contract type
    /// @return the dagora contract type
    function typeOf() public pure returns (string memory) {
        return "dAgora NFTAPlus";
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