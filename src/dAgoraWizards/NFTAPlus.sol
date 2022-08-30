/// @title Simple ERC721A Minting Contract
/// @author Made By DecentrAgora
/// @notice use this contract to enhance you understand of the ERC721 Standard
/// @dev 0xOrphan || DadlessNsad

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;

import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "ERC721A/ERC721A.sol";

/// @title NFT A Plus
/// @author 0xOrphan || DadlessNsad
/// @notice This contract is used as a template for creating new NFT contracts.
contract NFTAPlus is ERC721A, Ownable {
    /// @notice Where the NFTs metadata is stored.
    string public baseURI;

    /// @notice The file extension for the NFTs baseURI.
    string public baseExtension;

    /// @notice Used to store the allowed addresses for minting.
    /// @dev This is used to store the addresses that are allowed to mint NFTs during presale.
    bytes32 public merkleRoot;

    /// @notice Used to pause and unpause the contract.
    bool public paused = true;

    /// @notice Used to change and set the sale state of the contract.
    bool public preSale = true;

    /// @notice The maximum amount of NFTs that can be minted in one transaction.
    uint16 public bulkBuyLimit;

    /// @notice The maximum amount of NFTs that can be minted by a allowed listed address.
    uint16 public maxAllowListAmount;

    /// @notice The price to mint a new NFT.
    uint256 public mintCost;

    /// @notice The maximum amount of NFTs that can be minted.
    uint256 public maxTotalSupply;

    /// @notice Maps a address to the amount of NFTs they have minted.
    /// @dev This is used to keep track of the amount of NFTs a address has minted during presale.
    mapping(address => uint256) public presaleMintBalance;

    /// @notice Sets the contracts variables.
    /// @param _name The name of the NFT.
    /// @param _symbol The symbol of the NFT.
    /// @param _baseURI The baseURI of the NFT.
    /// @param _mintCost The cost to mint a new NFT.
    /// @param _bulkBuyLimit The maximum amount of NFTs that can be minted in one transaction.
    /// @param _maxAllowListAmount The max amount of NFTs that can be minted by a allowed listed address.
    /// @param _maxTotalSupply The maximum amount of NFTs that can be minted.
    /// @param _newOwner The address of the new owner.
    /// @param _merkleRoot The merkle root of the allowed addresses.
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
    )
        ERC721A(_name, _symbol)
    {
        baseURI = _baseURI;
        mintCost = _mintCost;
        bulkBuyLimit = _bulkBuyLimit;
        maxAllowListAmount = _maxAllowListAmount;
        maxTotalSupply = _maxTotalSupply;
        merkleRoot = _merkleRoot;
        transferOwnership(_newOwner);
    }

    /// @notice Checks if the contract is paused.
    /// @dev Used to prevent users from minting NFTs when the contract is paused.
    modifier notPaused() {
        require(!paused, "Contract is Paused");
        _;
    }

    modifier isValidMerkleProof(bytes32[] calldata merkleProof, bytes32 root) {
        require(
            MerkleProof.verify(merkleProof, root, keccak256(abi.encodePacked(msg.sender))),
            "Address does not exist in list"
        );
        _;
    }

    /// @notice Checks if the contract is in presale state.
    /// @dev Used to prevent users not in allow list from minting NFTs when the contract is in presale state.
    modifier isPresale() {
        require(preSale == true, "Presale not active");
        _;
    }

    /// @notice Checks if the contract is in public sale state.
    modifier isPublic() {
        require(!preSale, "Sale not Public");
        _;
    }

    /// @notice Function for allowlisted addresses to mint NFTs.
    /// @dev Used to mint NFTs during presale.
    /// @param proof The merkle proof of the msg.sender's address.
    /// @param _amount The amount of NFTs to mint.

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

    /// @notice Function for public to mint NFTs.
    /// @dev Used to mint NFTs during public sale.
    /// @param _amount The amount of NFTs to mint.
    function publicMint(uint256 _amount) public payable notPaused isPublic {
        require(_amount + totalSupply() <= maxTotalSupply, "Soldout");
        require(_amount <= bulkBuyLimit, "reached max per Tx");
        require(msg.value >= (_amount * mintCost), "Insufficient funds");

        _safeMint(msg.sender, _amount);
    }

    /// @notice Only Contract Owner can use this function to Mint NFTs.
    /// @param _amount The amount of NFTs to mint.
    /// @dev The total supply of NFTs must be less than or equal to the maxTotalSupply.
    function reserveTokens(uint256 _amount) public onlyOwner {
        require(_amount + totalSupply() <= maxTotalSupply, "Soldout");
        _safeMint(msg.sender, _amount);
    }

    function tokenURI(uint256 _tokenId)
        public
        view
        override
        returns (string memory)
    {
        require(_exists(_tokenId), "Token does not exist.");
        return string(abi.encodePacked(baseURI, _toString(_tokenId), ".json"));
    }

    /// @notice Allows contract owner to change the contracts sale state.
    /// @dev Used to change the contract from presale to public sale.
    function togglePaused() public onlyOwner {
        paused = !paused;
    }

    /// @notice Allows contract owner to change the contracts paused state.
    /// @dev Used to pause & unpause the contract.
    function togglePreSale() public onlyOwner {
        preSale = !preSale;
    }

    /// @notice Allows the owner to change the baseURI.
    /// @param _baseURI The new baseURI.
    function setBaseURI(string memory _baseURI) public onlyOwner {
        baseURI = _baseURI;
    }

    /// @notice Allows the owner to change the Base extension.
    /// @param _newBaseExtension The new baseExtension.
    function setBaseExtension(string memory _newBaseExtension)
        public
        onlyOwner
    {
        baseExtension = _newBaseExtension;
    }

    /// @notice Allows the owner to change the merkle root.
    /// @param _merkleRoot The new merkle root.
    function setMerkleRoot(bytes32 _merkleRoot) public onlyOwner {
        merkleRoot = _merkleRoot;
    }

    /// @notice Allows the owner to change the mint cost.
    /// @param _newMintCost The new mint cost.
    function setMintCost(uint256 _newMintCost) public onlyOwner {
        mintCost = _newMintCost;
    }

    /// @param _newBulkBuyLimit The new bulkBuyLimit.
    /// @dev The bulkBuyLimit must be less than the maxTotalSupply.
    function setBulkBuyLimit(uint16 _newBulkBuyLimit) public onlyOwner {
        require(_newBulkBuyLimit != 0, "Bulk Buy Limit must be greater than 0");
        require(
            _newBulkBuyLimit < maxTotalSupply,
            "Bulk Buy Limit must be less than Max Total Supply"
        );
        bulkBuyLimit = _newBulkBuyLimit;
    }

    /// @notice Allows the owner to change the max allow list amount.
    /// @param _newAllowListAmount The new max allow list amount.
    function setMaxAllowListAmount(uint16 _newAllowListAmount)
        public
        onlyOwner
    {
        require(
            _newAllowListAmount < bulkBuyLimit,
            "Max Allow List Amount must be less than Bulk Buy Limit"
        );
        maxAllowListAmount = _newAllowListAmount;
    }

    /// @notice Allows the owner to withdraw ether from contract.
    /// @dev The owner can only withdraw ether from the contract.
    function withdraw() public onlyOwner {
        (bool success,) =
            payable(msg.sender).call{value: address(this).balance}("");
        require(success, "Address: unable to send value");
    }

    /// @notice Allows owner to withdraw any ERC20 tokens sent to this contract.
    /// @param _tokenAddr The address of the ERC20 token.
    /// @dev Only Contract Owner can use this function.
    function withdrawErc20s(address _tokenAddr) public onlyOwner {
        (bool success,) =
            payable(msg.sender).call{value: address(_tokenAddr).balance}("");
        require(success, "Address: unable to send value");
    }

    function _startTokenId() internal view virtual override returns (uint256) {
        return 1;
    }
}
